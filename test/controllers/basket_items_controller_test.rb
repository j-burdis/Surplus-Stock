require "test_helper"

class BasketItemsControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get basket_items_create_url
    assert_response :success
  end

  test "should get destroy" do
    get basket_items_destroy_url
    assert_response :success
  end
end
