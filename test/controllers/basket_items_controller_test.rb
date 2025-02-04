require "test_helper"

class BasketItemsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @user = users(:alice)
    @item = items(:floor_lamp)
    @basket_item = basket_items(:lamp_in_alice_basket)
    sign_in @user
  end

  test "should create basket item via HTML" do
    assert_difference "BasketItem.count", 1 do
      post basket_items_url, params: { item_id: @item.id, quantity: 1 }
    end

    assert_redirected_to basket_path
    assert_equal "#{@item.name} has been added to your basket.", flash[:notice]
  end

  test "should create basket item via JSON" do
    assert_difference "BasketItem.count", 1 do
      post basket_items_url, 
        params: { item_id: @item.id, quantity: 1 },
        as: :json
    end

    assert_response :success
    json_response = JSON.parse(response.body)

    assert json_response['success']
    assert_equal "#{@item.name} has been added to your basket.", json_response['message']
    assert_equal 'notice', json_response['flash']['type']
  end

  ##### add methods for updating existing basket item quantity via HTML and JSON #######

  # test "cannot add more items than stock via HTML" do
  #   assert_no_difference "BasketItem.count" do
  #     post basket_items_url, params: {
  #       item_id: @item.id,
  #       quantity: 15 # more than available stock
  #     }
  #   end

  #   assert_redirected_to item_path(@item)
  #   assert_equal "Not enough stock available.", flash[:alert]
  # end

  #### add method for JSON ####

  test "should destroy basket item" do
    delete basket_item_url(@basket_item)
    assert_redirected_to basket_path
  end
end
