ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "minitest/rails"
require "minitest/reporters"
require "devise"

Minitest::Reporters.use!(
  Minitest::Reporters::DefaultReporter.new(
    show_progress: true,
    color: true
  ),
  ENV,
  Minitest.backtrace_filter
)

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  include Devise::Test::IntegrationHelpers

  # Enhanced debugging setup
  # setup do
  #   # Print out detailed information about existing records
  #   puts "Users in database:"
  #   User.all.each do |user|
  #     puts "  ID: #{user.id}, Email: #{user.email}"
  #   end

  #   puts "\nBaskets in database:"
  #   Basket.all.each do |basket|
  #     puts "  ID: #{basket.id}, User ID: #{basket.user_id}"
  #   end

  #   puts "\nItems in database:"
  #   Item.all.each do |item|
  #     puts "  ID: #{item.id}, Name: #{item.name}, User ID: #{item.user_id}"
  #   end
  # end
end
