require 'net/http'
require 'json'
require 'uri'

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
      begin
        Rails.logger.info "Finding postcodes near #{origin} within #{radius_miles} miles"

        origin_location = geocode(origin)
        Rails.logger.info "Origin location: #{origin_location.inspect}"
        return [] unless origin_location

        radius_meters = (radius_miles * 1609.34).to_i
        Rails.logger.info "Search radius in meters: #{radius_meters}"

        url = URI("https://maps.googleapis.com/maps/api/place/nearbysearch/json")
        params = {
          location: "#{origin_location[:lat]},#{origin_location[:lng]}",
          radius: radius_meters,
          type: 'postal_code',
          key: ENV.fetch('GOOGLE_MAPS_API_KEY') { raise "Google Maps API key not found" }
        }

        url.query = URI.encode_www_form(params)
        Rails.logger.info "Making request to Google Places API: #{url.to_s.gsub(ENV.fetch('GOOGLE_MAPS_API_KEY', nil), '[REDACTED]')}"

        response = Net::HTTP.get_response(url)
        data = JSON.parse(response.body)

        # Rails.logger.info "Google Places API response status: #{data['status']}"
        # Rails.logger.info "Number of results: #{data['results']&.length || 0}"

        # if data['status'] == 'OK'
        #   postcodes = data['results'].map { |result| result['vicinity'] }.compact.uniq
        #   Rails.logger.info "Found postcodes: #{postcodes}"
        #   postcodes
        # else
        #   Rails.logger.error "Google Places API error: #{data['status']}"
        #   Rails.logger.error "Error details: #{data['error_message']}" if data['error_message']
        #   []
        # end
        if data['status'] == 'OK'
          # Get unique postcodes from results
          postcodes = []
          data['results'].each do |result|
            # Get detailed address info for each result
            detail_url = URI("https://maps.googleapis.com/maps/api/geocode/json")
            detail_params = {
              place_id: result['place_id'],
              key: ENV.fetch('GOOGLE_MAPS_API_KEY')
            }

            detail_url.query = URI.encode_www_form(detail_params)
            detail_response = Net::HTTP.get_response(detail_url)
            detail_data = JSON.parse(detail_response.body)

            if detail_data['status'] == 'OK'
              detail_data['results'].each do |detail_result|
                postal_code = detail_result['address_components']
                  .find { |component| component['types'].include?('postal_code') }
                  &.dig('long_name')

                if postal_code
                  # Verify distance is within radius
                  result_lat = detail_result.dig('geometry', 'location', 'lat')
                  result_lng = detail_result.dig('geometry', 'location', 'lng')

                  if result_lat && result_lng
                    distance = calculate_distance(
                      origin_location[:lat], origin_location[:lng],
                      result_lat, result_lng
                    )

                    postcodes << postal_code if distance <= radius_miles
                  end
                end
              end
            end
          end
          postcodes.uniq!
          Rails.logger.info "Found postcodes within #{radius_miles} miles: #{postcodes}"
          postcodes
        else
          Rails.logger.error "Google Places API error: #{data['status']}"
          Rails.logger.error "Error details: #{data['error_message']}" if data['error_message']
          []
        end
      rescue StandardError => e
        Rails.logger.error "Nearby postcodes error: #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
        []
      end
    end

    private

    def extract_component(components, type)
      components&.find { |c| c['types'].include?(type) }&.dig('long_name')
    end

    def calculate_distance(lat1, lon1, lat2, lon2)
      rad_per_deg = Math::PI/180
      rm = 3959 # Earth radius in miles

      dlat_rad = (lat2-lat1) * rad_per_deg
      dlon_rad = (lon2-lon1) * rad_per_deg

      lat1_rad = lat1 * rad_per_deg
      lat2_rad = lat2 * rad_per_deg

      a = (Math.sin(dlat_rad/2)**2) +
          (Math.cos(lat1_rad) * Math.cos(lat2_rad) *
          (Math.sin(dlon_rad / 2)**2))
      c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))

      rm * c # Return distance in miles
    end
  end
end
