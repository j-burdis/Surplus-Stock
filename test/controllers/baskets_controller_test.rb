require "test_helper"

class BasketsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  
  def setup
    @user = users(:alice)
    @basket = baskets(:alice_basket)
    sign_in @user
  end

  test "should get show" do
    get basket_url(@basket, format: :html)
    assert_response :success
  end
end
