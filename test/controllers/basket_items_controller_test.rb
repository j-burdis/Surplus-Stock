require "test_helper"

class BasketItemsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @user = users(:alice)
    @item = items(:table_lamp)
    @basket_item = basket_items(:lamp_in_alice_basket)
    sign_in @user
  end

  test "should create basket item" do
    post basket_items_url, params: { item_id: @item.id, quantity: 1 }

    assert_redirected_to basket_path
    assert_equal "#{@item.name} has been added to your basket.", flash[:notice]
  end

  test "cannot add more items than stock" do
    post basket_items_url, params: {
      item_id: @item.id,
      quantity: 15 # more than available stock
    }

    assert_redirected_to item_path(@item)
    assert_equal "Not enough stock available.", flash[:alert]
  end

  test "should destroy basket item" do
    delete basket_item_url(@basket_item)
    assert_redirected_to basket_path
  end
end
