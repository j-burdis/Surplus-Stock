require "test_helper"

class BasketItemTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  
  def setup
    @user = users(:alice)
    @item = items(:table_lamp)
    @basket = @user.basket || Basket.create(user: @user)
  end

  test "basket item is valid with valid attributes" do
    basket_item = BasketItem.new(
      basket: @basket,
      item: @item,
      quantity: 2
    )
    assert basket_item.valid?, "BasketItem should be valid with correct attributes"
  end

  test "quantity must be positive" do
    basket_item = BasketItem.new(
      basket: @basket,
      item: @item,
      quantity: 0
    )
    assert_not basket_item.valid?, "BasketItem should be invalid with zero quantity"
  end

  test "expired? method works" do
    old_basket_item = BasketItem.create(
      basket: @basket,
      item: @item,
      quantity: 1,
      created_at: 1.hour.ago
    )
    assert old_basket_item.expired?, "BasketItem should be considered expired after 30 minutes"
  end
end
