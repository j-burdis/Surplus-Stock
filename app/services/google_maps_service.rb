require 'net/http'
require 'json'
require 'uri'

class GoogleMapsService
  def self.lookup_addresses(postcode)
    # Add input validation
    return [] if postcode.blank?

    begin
      url = URI("https://maps.googleapis.com/maps/api/geocode/json")
      params = {
        address: postcode,
        region: 'uk',
        key: ENV.fetch('GOOGLE_MAPS_API_KEY', nil)
      }

      url.query = URI.encode_www_form(params)
      response = Net::HTTP.get_response(url)

      data = JSON.parse(response.body)
      return [] unless data['status'] == 'OK' && data['results'].any?

      data['results'].map do |result|
        components = result['address_components']

        # Extract address components
        street = components.find { |c| c['types'].include?('route') }
        city = components.find { |c| c['types'].include?('postal_town') }
        postcode_data = components.find { |c| c['types'].include?('postal_code') }

        {
          formatted_address: result['formatted_address'],
          street_address: street&.dig('long_name'),
          city: city&.dig('long_name'),
          postcode: postcode_data&.dig('long_name') || postcode,
          coordinates: [
            result.dig('geometry', 'location', 'lng'),
            result.dig('geometry', 'location', 'lat')
          ]
        }
      end
    rescue StandardError
      []
    end
  end

  def self.geocode(postcode)
    return nil if postcode.blank?

    begin
      # Use your existing lookup_addresses method
      results = lookup_addresses(postcode)
      return nil if results.empty?

      first_result = results.first
      {
        lat: first_result[:coordinates][1],
        lng: first_result[:coordinates][0]
      }
    rescue StandardError => e
      Rails.logger.error "Geocoding error: #{e.message}"
      nil
    end
  end

  def self.find_nearby_postcodes(origin, radius_miles)
    begin
      origin_location = geocode(origin)
      return [] unless origin_location

      radius_meters = radius_miles * 1609.34

      url = URI("https://maps.googleapis.com/maps/api/place/nearbysearch/json")
      params = {
        location: "#{origin_location[:lat]},#{origin_location[:lng]}",
        radius: radius_meters.to_i,
        type: 'postal_code',
        key: ENV.fetch('GOOGLE_MAPS_API_KEY', nil)
      }

      url.query = URI.encode_www_form(params)
      response = Net::HTTP.get_response(url)
      data = JSON.parse(response.body)

      if data['status'] == 'OK'
        data['results'].map { |result| result['vicinity'] }.compact.uniq
      else
        Rails.logger.error "Google Places API error: #{data['status']}"
        []
      end
    rescue StandardError => e
      Rails.logger.error "Nearby postcodes error: #{e.message}"
      []
    end
  end
end
