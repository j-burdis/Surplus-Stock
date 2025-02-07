ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "minitest/rails"
require "minitest/reporters"
require "devise"

Minitest::Reporters.use!(
  # Minitest::Reporters::SpecReporter.new,
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

  def self.fixtures(*fixture_set_names)
    if fixture_set_names.first == :all
      fixture_set_names = [
        :users,    # load users first since they're referenced by other tables
        :baskets,
        :items,
        :orders,
        :basket_items
      ]
    end
    super(fixture_set_names)
  end

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  include Devise::Test::IntegrationHelpers

  # def before_setup
  #   # Enable this block temporarily to see what's in the database
  #   puts "\n=== Database State Before Test ==="
  #   puts "Users:"
  #   User.all.each { |u| puts "  ID: #{u.id}, Email: #{u.email}" }
    
  #   puts "\nOrders:"
  #   Order.all.each { |o| puts "  ID: #{o.id}, User ID: #{o.user_id}" }
    
  #   puts "\nBaskets:"
  #   Basket.all.each { |b| puts "  ID: #{b.id}, User ID: #{b.user_id}" }
    
  #   puts "============================\n"
  #   super
  # end
end
