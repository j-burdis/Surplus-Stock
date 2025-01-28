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

      Rails.logger.info "Google Maps API Query: #{postcode}, United Kingdom"

      data = JSON.parse(response.body)
      Rails.logger.info "Google Maps API Query: #{postcode}, United Kingdom"

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
    rescue StandardError => e
      Rails.logger.error "Google Maps lookup error: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      []
    end
  end
end
