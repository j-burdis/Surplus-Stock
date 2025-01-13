# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

require "json"
require "open-uri"

puts "Clearing existing items..."

Item.destroy_all

puts "Seeding items from API..."

begin
  api_url = "https://furniture-api.fly.dev/v1/products"
  response = URI.open(api_url).read
  data = JSON.parse(response)

  products = data["data"] # Access the "data" array in the response

  products.each do |product|
    Item.create!(
      name: product["name"],
      description: product["description"],
      price: product["price"],
      image_url: product["image_path"],
      stock: rand(40..50),
      category: product["category"],
      discount_price: product["discount_price"]&.round,
      user_id: User.first&.id || 2 # Assign to the first user or a default user ID
    )
  end

  puts "Seeding completed successfully!"
rescue OpenURI::HTTPError => e
  puts "HTTP Error: #{e.message}"
rescue JSON::ParserError => e
  puts "JSON Parsing Error: #{e.message}"
rescue => e
  puts "An unexpected error occurred: #{e.message}"
end
