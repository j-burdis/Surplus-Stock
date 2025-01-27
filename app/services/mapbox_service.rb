class MapboxService
  def self.lookup_addresses(postcode)
    Mapbox.access_token = ENV.fetch('MAPBOX_API_KEY', nil)

    # Add input validation
    return [] if postcode.blank?

    begin
      # Search for addresses in the UK with the given postcode
      response = Mapbox::Geocoder.geocode_forward(
        "#{postcode}, United Kingdom",
        {
          types: ['address'],
          country: ['gb'],
          limit: 10, # Adjust this number based on how many results you want
          autocomplete: true
        }
      )

      Rails.logger.info "Mapbox API Query: #{postcode}, United Kingdom"
      Rails.logger.info "Mapbox API Response: #{response.inspect}"

      # Get the features from the first item in response (the FeatureCollection)
      features = begin
        response.first['features']
      rescue StandardError
        []
      end
      return [] unless features&.any?

      features.map do |feature|
        # Rails.logger.info "Processing feature: #{feature.inspect}"

        # Extract the address components
        context = feature['context'] || []
        postcode_data = context.find { |c| c['id']&.start_with?('postcode') }
        city_data = context.find { |c| c['id']&.start_with?('place') }
        locality_data = context.find { |c| c['id']&.start_with?('locality') }

        {
          formatted_address: feature['place_name'],
          street_address: feature['text'],
          city: city_data&.dig('text') || locality_data&.dig('text'),
          postcode: postcode_data&.dig('text') || postcode,
          coordinates: feature['center'] # [longitude, latitude]
        }
      end
    rescue StandardError => e
      Rails.logger.error "Mapbox lookup error: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      []
    end
  end
end
