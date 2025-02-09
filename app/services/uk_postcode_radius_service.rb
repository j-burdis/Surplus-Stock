class UKPostcodeRadiusService
  class << self
    def find_nearby_postcodes(origin:, radius_miles:)
      return [] if origin.blank?

      begin
        Rails.logger.info "Finding postcodes near #{origin} within #{radius_miles} miles"

        # First, we need to get the latitude and longitude for the origin postcode
        coordinates = get_postcode_coordinates(origin)
        return [] unless coordinates

        # Now we can make the radius search request
        base_url = "https://uk-postcodes-inside-radius.p.rapidapi.com/"
        query_params = URI.encode_www_form({
          lat: coordinates[:lat],
          lng: coordinates[:lng],
          radius: (radius_miles * 1.60934).round(3), # Convert miles to km
          country: 'GB'
        })
        url = URI("#{base_url}?#{query_params}")

        Rails.logger.debug "Making request to: #{url}"
        Rails.logger.debug "Coordinates for request: lat=#{coordinates[:lat]}, lng=#{coordinates[:lng]}"

        # Create HTTP request
        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true

        # Set up the request with headers
        request = Net::HTTP::Get.new(url)
        request["X-RapidAPI-Key"] = ENV.fetch('RAPIDAPI_KEY') { raise "RapidAPI key not found" }
        request["X-RapidAPI-Host"] = 'uk-postcodes-inside-radius.p.rapidapi.com'

        Rails.logger.level = :debug
        response = http.request(request)

        # Log the response for debugging
        Rails.logger.debug "Response code: #{response.code}"
        Rails.logger.debug "Response body: #{response.body}"

        # Parse and process response
        data = JSON.parse(response.body)

        if response.code == "200"
          if data["status"] == 1 && data["output"].is_a?(Array)
            # Handle successful response
            postcodes = data["output"].map { |result| result["postcode"] }
            Rails.logger.info "Found #{postcodes.length} postcodes within #{radius_miles} miles of #{origin}"
            postcodes.uniq
          else
            Rails.logger.error "API Error: #{data['msg']}"
            []
          end
        else
          Rails.logger.error "API Error: #{data['msg'] || response.message}"
          []
        end
      rescue JSON::ParserError => e
        Rails.logger.error "JSON parsing error: #{e.message}"
        Rails.logger.error "Response body was: #{response&.body}"
        []
      rescue StandardError => e
        Rails.logger.error "Nearby postcodes error: #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
        []
      end
    end

    private

    def get_postcode_coordinates(postcode)
      # We can use your existing GoogleMapsService to get coordinates
      location = GoogleMapsService.geocode(postcode)

      if location
        Rails.logger.info "Found coordinates for #{postcode}: #{location[:lat]}, #{location[:lng]}"
        location
      else
        Rails.logger.error "Could not get coordinates for postcode: #{postcode}"
        nil
      end
    end
  end
end
