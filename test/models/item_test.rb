require "test_helper"

class ItemTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  
  def setup
    @item = items(:table_lamp)
  end

  test "item is valid" do
    assert @item.valid?, "Item should be valid with all attributes"
  end

  test "item requires a name" do 
    @item.name = nil
    assert_not @item.valid?, "Item should be invalid without a name"
  end

  test "price must be non-negative" do
    @item.price = -10
    assert_not @item.valid?, "Item should be invalid with a negative price"
  end

  test "stock cannot be negative" do
    @item.stock = -1
    assert_not @item.valid?, "Item should be invalid with negative stock"
  end

  test "stock_available? method works correctly" do
    assert @item.stock_available?(5), "Should return true when enough stock is available"
    assert_not @item.stock_available?(15), "Should return false when not enough stock is available"
  end
end
