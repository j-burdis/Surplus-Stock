class DeliveryService
  DEPOT_POSTCODE = 'NE42 6HD'
  MAX_DAILY_DELIVERIES = 10
  DELIVERY_BLACKOUT_DAYS = 7
  NEARBY_RADIUS_MILES = 3

  def initialize(delivery_postcode)
    @delivery_postcode = delivery_postcode
    raise ArgumentError, "Invalid postcode" if @delivery_postcode.blank?
  end

  def available_dates
    Rails.logger.info "Starting available dates calculation for postcode: #{@delivery_postcode}"
    return [] unless valid_delivery_area?

    # Get nearby deliveries in the next 7 days
    nearby_delivery_dates = find_nearby_delivery_dates
    Rails.logger.info "Found nearby delivery dates: #{nearby_delivery_dates.map { |d| "#{d[:postcode]} on #{d[:date]}" }}"

    if nearby_delivery_dates.empty?
      # If no nearby deliveries, return all business days in next 30 days
      # that have delivery slots available
      Rails.logger.info "No nearby deliveries found - checking all business days"
      dates = next_30_business_days
      available = filter_dates_by_capacity(dates)
      Rails.logger.info "Available dates after capacity check: #{available.map(&:to_s)}"
      return available
    end

    # Group the dates by delivery zones
    dates_by_zone = nearby_delivery_dates.group_by { |date| determine_delivery_zone(date[:postcode]) }
    delivery_zone = determine_delivery_zone(@delivery_postcode)

    Rails.logger.info "Customer postcode zone: #{delivery_zone}"
    Rails.logger.info "Existing delivery dates by zone: #{dates_by_zone.transform_values { |dates| dates.map { |d| d[:date] }}}"

    available_dates = []
    dates = next_30_business_days

    dates.each do |date|
      Rails.logger.debug "Checking date: #{date}"
      # Skip if max deliveries reached
      # next unless deliveries_available?(date)
      unless deliveries_available?(date)
        Rails.logger.debug "#{date} skipped - maximum deliveries reached"
        next
      end

      # If there are deliveries in our zone on this date, add it
      if dates_by_zone[delivery_zone]&.any? { |d| d[:date] == date }
        Rails.logger.info "#{date} added - matches existing delivery zone"
        available_dates << date
        next
      end

      # If the date is after the blackout period of all nearby deliveries
      if nearby_delivery_dates.all? { |d| date > d[:date] + DELIVERY_BLACKOUT_DAYS.days }
        Rails.logger.info "#{date} added - after all blackout periods"
        available_dates << date
      else
        blocking_deliveries = nearby_delivery_dates.select { |d| date <= d[:date] + DELIVERY_BLACKOUT_DAYS.days }
        Rails.logger.debug "#{date} blocked by deliveries: #{blocking_deliveries.map { |d| "#{d[:postcode]} on #{d[:date]}" }}"
      end
    end

    Rails.logger.info "Final available dates: #{available_dates.map(&:to_s)}"
    available_dates
  rescue StandardError => e
    Rails.logger.error "Error getting available dates: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    []
  end

  private

  def find_nearby_delivery_dates
    nearby_postcodes = GoogleMapsService.find_nearby_postcodes(
      origin: @delivery_postcode,
      radius_miles: NEARBY_RADIUS_MILES
    )

    Rails.logger.info "Found nearby postcodes: #{nearby_postcodes}"

    date_range = Date.tomorrow..7.days.from_now
    Rails.logger.info "Checking date range: #{date_range}"

    # Get all deliveries in nearby postcodes for next 7 days
    deliveries = Order.where(display_postcode: nearby_postcodes)
                      .where(delivery_date: date_range)
                      .where(status: ['paid', 'processing'])
                      .pluck(:display_postcode, :delivery_date)
                      .map { |postcode, date| { postcode: postcode, date: date } }

    Rails.logger.info "Found existing deliveries: #{deliveries.map { |d| "#{d[:postcode]} on #{d[:date]}" }}"
    deliveries
  end

  def filter_dates_by_capacity(dates)
    # dates.select { |date| deliveries_available?(date) }
    available_dates = dates.select do |date| 
      available = deliveries_available?(date)
      Rails.logger.debug "Date #{date} capacity check: #{available ? 'available' : 'full'}"
      available
    end

    Rails.logger.info "Dates after capacity filter: #{available_dates.map(&:to_s)}"
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
    # Order.where(delivery_date: date, status: ['paid', 'processing'])
    #      .count < MAX_DAILY_DELIVERIES
    count = Order.where(delivery_date: date, status: ['paid', 'processing']).count
    Rails.logger.debug "Delivery count for #{date}: #{count}/#{MAX_DAILY_DELIVERIES}"
    count < MAX_DAILY_DELIVERIES
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
end
