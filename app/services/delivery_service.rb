class DeliveryService
  DEPOT_POSTCODE = 'NE42 6HD'
  MAX_DAILY_DELIVERIES = 10
  DELIVERY_BLACKOUT_DAYS = 7

  def initialize
    @delivery_postcode = delivery_postcode
  end

  def available_dates
    return [] unless valid_delivery_area?

    dates = next_30_business_days
    filter_dates(dates)
  end

  private
  def valid_delivery_area?
    return false unless @delivery_postcode

    location = GoogleMapsService.geocode(@delivery_postcode)
    return false unless location && in_north_east?(location)

    true
  end

  def in_north_east?(location)
    # rough bounds for NE England
    ne_bounds = {
      north: 55.811, south: 54.361,
      east: -1.011, west: -2.521
    }

    lat = location[:lat]
    lng = location[:lng]

    lat.between?(ne_bounds[:south], ne_bounds[:north]) &&
      lng.between?(ne_bounds[:west], ne_bounds[:east])
  end

  def next_30_business_days
    dates = []
    date = Date.today
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
      deliveries_available?(date) &&
        !recent_delivery_nearby?(date) &&
        compatible_with_route?(date)
    end
  end

  def deliveries_available?(date)
    Order.where(delivery_date: date, status: ['paid', 'processing'])
      .count < MAX_DAILY_DELIVERIES
  end

  def recent_delivery_nearby?(date)
    nearby_postcodes = find_nearby_postocodes

    Order
      .where(display_postcode: nearby_postcodes)
      .where(delivery_date: (date - DELIVERY_BLACKOUT_DAYS.DAYS)..date)
      .where(status: ['paid', 'processing'])
      .exists?
  end

  def find_nearby_postocodes
    nearby_orders = GoogleMapsService.find_nearby_postocodes(
      origin: @delivery_postcode,
      radius_miles: 3
    )

    nearby_orders.map(&:display_postcode)
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
