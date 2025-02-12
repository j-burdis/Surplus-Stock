class DeliveryService
  DEPOT_POSTCODE = 'NE42 6HD'
  MAX_DAILY_DELIVERIES = 10
  DELIVERY_BLACKOUT_DAYS = 7
  NEARBY_RADIUS_MILES = 3

  def initialize(delivery_postcode)
    @delivery_postcode = delivery_postcode
    raise ArgumentError, "Invalid postcode" if @delivery_postcode.blank?

    @delivery_zone = determine_delivery_zone
    Rails.logger.info "Initialized delivery service for postcode: #{@delivery_postcode} in zone: #{@delivery_zone}"
  end

  def available_dates
    Rails.logger.info "Starting available dates calculation for postcode: #{@delivery_postcode} in zone: #{@delivery_zone}"
    return [] unless valid_delivery_area?

    existing_deliveries = find_existing_deliveries
    Rails.logger.info "Found existing deliveries: #{existing_deliveries.map { |d| "#{d[:postcode]} on #{d[:date]} in zone #{d[:zone]}" }}"

    zone_deliveries = existing_deliveries.select { |d| d[:zone] == @delivery_zone }
    Rails.logger.info "Deliveries in zone #{@delivery_zone}: #{zone_deliveries.map { |d| d[:date] }}"

    # get nearby deliveries in the next 7 days
    nearby_delivery_dates = find_nearby_delivery_dates(zone_deliveries)
    Rails.logger.info "Found nearby delivery dates: #{nearby_delivery_dates.map { |d| "#{d[:postcode]} on #{d[:date]}" }}"

    available_dates = calculate_available_dates(nearby_delivery_dates, existing_deliveries)
    Rails.logger.info "Final available dates: #{available_dates.map(&:to_s)}"

    available_dates
  rescue StandardError => e
    Rails.logger.error "Error getting available dates: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    []
  end

  private

  def find_existing_deliveries
    # get all deliveries for next 30 business days
    end_date = calculate_end_date
    date_range = Date.tomorrow..end_date

    Order.where(delivery_date: date_range)
         .where(status: ['paid', 'processing'])
         .pluck(:display_postcode, :delivery_date)
         .map do |postcode, date|
           {
             postcode: postcode,
             date: date,
             zone: determine_delivery_zone(postcode)
           }
         end
  end

  def calculate_end_date
    date = Date.tomorrow
    business_days = 0

    while business_days < 30
      business_days += 1 unless date.sunday?
      date += 1.day
    end

    date - 1.day
  end

  def find_nearby_delivery_dates(zone_deliveries)
    nearby_postcodes = GoogleMapsService.find_nearby_postcodes(
      origin: @delivery_postcode,
      radius_miles: NEARBY_RADIUS_MILES
    )

    zone_deliveries.select { |delivery| nearby_postcodes.include?(delivery[:postcode]) }
  end

  def calculate_available_dates(nearby_delivery_dates, all_deliveries)
    available_dates = []
    dates = next_30_business_days

    dates.each do |date|
      next unless deliveries_available?(date)

      # check for deliveries in different zones
      other_zone_delivery = all_deliveries.any? do |delivery|
        delivery[:date] == date && delivery[:zone] != @delivery_zone
      end

      # skip if there's a delivery in a different zone
      next if other_zone_delivery

      # check if date is during a blackout period
      in_blackout_period = nearby_delivery_dates.any? do |delivery|
        # skip blackout check if it's the same day
        next false if delivery[:date] == date

        # check if date falls within blackout period
        date.between?(delivery[:date] - DELIVERY_BLACKOUT_DAYS.days,
                      delivery[:date] + DELIVERY_BLACKOUT_DAYS.days)
      end

      # add date if it's not in a blackout period OR if there's already a nearby delivery on this date
      if !in_blackout_period || nearby_deliveries.any? { |d| d[:date] == date }
        available_dates << date
      end
    end

    available_dates
  end

  def next_30_business_days
    dates = []
    date = Date.tomorrow
    while dates.length < 30
      dates << date if business_day?(date)
      date += 1.day
    end
    dates
  end

  def business_day?(date)
    !date.sunday?
  end

  def deliveries_available?(date)
    count = Order.where(delivery_date: date, status: ['paid', 'processing']).count
    Rails.logger.debug "Delivery count for #{date}: #{count}/#{MAX_DAILY_DELIVERIES}"
    count < MAX_DAILY_DELIVERIES
  end

  def determine_delivery_zone(postcode = @delivery_postcode)
    location = GoogleMapsService.geocode(postcode)
    depot = GoogleMapsService.geocode(DEPOT_POSTCODE)

    return :unknown unless location && depot

    if location[:lng] > depot[:lng]
      location[:lat] > 54.96 ? :north_tyne : :south_tyne
    else
      :west
    end
  end

  def valid_delivery_area?
    location = GoogleMapsService.geocode(@delivery_postcode)
    return false unless location

    north_east_bounds = {
      north: 55.811, south: 54.361,
      east: -1.011, west: -2.521
    }

    lat, lng = location.values_at(:lat, :lng)
    lat.between?(north_east_bounds[:south], north_east_bounds[:north]) &&
      lng.between?(north_east_bounds[:west], north_east_bounds[:east])
  rescue StandardError => e
    Rails.logger.error "Error validating delivery area: #{e.message}"
    false
  end
end
