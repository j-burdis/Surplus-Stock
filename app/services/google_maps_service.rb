# app/services/google_maps_service.rb
require 'net/http'
require 'json'
require 'uri'
require_relative 'uk_postcode_radius_service'
class GoogleMapsService
  class << self
    def lookup_addresses(postcode)
      # Add input validation
      return [] if postcode.blank?

      begin
        # Get API key once at class level
        api_key = ENV.fetch('GOOGLE_MAPS_API_KEY') { raise "Google Maps API key not found" }

        url = URI("https://maps.googleapis.com/maps/api/geocode/json")
        params = {
          address: postcode,
          region: 'uk',
          key: api_key
        }

        url.query = URI.encode_www_form(params)
        response = Net::HTTP.get_response(url)

        data = JSON.parse(response.body)
        # return [] unless data['status'] == 'OK' && data['results'].any?
        if data['status'] != 'OK'
          Rails.logger.error "Google Maps API error: #{data['status']} for postcode: #{postcode}"
          return []
        end

        data['results'].map do |result|
          components = result['address_components']

          {
            formatted_address: result['formatted_address'],
            street_address: extract_component(components, 'route'),
            city: extract_component(components, 'postal_town'),
            postcode: extract_component(components, 'postal_code') || postcode,
            coordinates: [
              result.dig('geometry', 'location', 'lng'),
              result.dig('geometry', 'location', 'lat')
            ]
          }
        end
      rescue StandardError => e
        Rails.logger.error "Address lookup error: #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
        []
      end
    end

    def geocode(postcode)
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

    def find_nearby_postcodes(origin:, radius_miles:)
      UKPostcodeRadiusService.find_nearby_postcodes(
        origin: origin,
        radius_miles: radius_miles
      )
    end

    private

    def extract_component(components, type)
      components&.find { |c| c['types'].include?(type) }&.dig('long_name')
    end
  end
end
