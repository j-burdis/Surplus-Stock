require "test_helper"

class BasketItemTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  
  def setup
    @user = users(:alice)
    @item = items(:table_lamp)
    @basket = @user.basket
    @basket_item = BasketItem.create(
      basket: @basket,
      item: @item,
      quantity: 2
    )
  end

  test "basket item is valid" do
    assert @basket_item.valid?
  end

  test "quantity must be positive" do
    @basket_item.quantity = 0
    assert_not @basket_item.valid?
  end

  test "expired? method works" do
    old_basket_item = BasketItem.create(
      basket: @basket,
      item: @item,
      quantity: 1,
      created_at: 1.hour.ago
    )
    assert old_basket_item.expired?
  end
end
