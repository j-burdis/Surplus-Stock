# config/initializers/google_maps.rb
if ENV['GOOGLE_MAPS_API_KEY'].blank?
  Rails.logger.warn 'GOOGLE_MAPS_API_KEY is not set. Address lookup functionality will not work.'
end