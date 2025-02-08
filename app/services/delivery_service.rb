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
    return [] unless valid_delivery_area?

    dates = next_30_business_days
    filter_dates(dates)
  rescue StandardError => e
    Rails.logger.error "Error getting available dates: #{e.message}"
    []
  end

  private

  # check postcode is roguhly in NE England
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

  def filter_dates(dates)
    dates.select do |date|
      business_day?(date) &&
        deliveries_available?(date) &&
        !recent_delivery_nearby?(date) &&
        compatible_with_route?(date)
    end
  end

  def deliveries_available?(date)
    Order.where(delivery_date: date, status: ['paid', 'processing'])
      .count < MAX_DAILY_DELIVERIES
  end

  # checks recent deliveries within 3 miles - prevents revisiting same area
  def recent_delivery_nearby?(date)
    nearby_postcodes = GoogleMapsService.find_nearby_postcodes(
      origin: @delivery_postcode,
      radius_miles: NEARBY_RADIUS_MILES
    )

    recent_deliveries = Order
                        .where(display_postcode: nearby_postcodes)
                        .where(delivery_date: (date - DELIVERY_BLACKOUT_DAYS.days)..date)
                        .where(status: ['paid', 'processing'])
                        .exists?

    recent_deliveries
  end

  def compatible_with_route?(date)
    existing_deliveries = Order
                          .where(delivery_date: date)
                          .where(status: ['paid', 'processing'])
                          .pluck(:display_postcode)

    return true if existing_deliveries.empty?

    delivery_zone = determine_delivery_zone
    exisiting_zones = existing_deliveries.map { |pc| determine_delivery_zone(pc) }

    exisiting_zones.include?(delivery_zone)
  end

  def determine_delivery_zone(postcode = @delivery_postcode)
    location = GoogleMapsService.geocode(postcode)
    depot = GoogleMapsService.geocode(DEPOT_POSTCODE)

    return :unknown unless location && depot

    # if east of depot
    if location[:lng] > depot[:lng]
      # if east of depot, split by river
      location[:lat] > 54.96 ? :north_tyne : :south_tyne
    else
      # west is one zone for now
      :west
    end
  end
end
