require "test_helper"

class ItemTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  
  def setup
    @item = items(:table_lamp)
  end

  test "item is valid" do
    assert @item.valid?
  end

  test "item requires a name" do 
    @item.name = nil
    assert_not @item.valid?
  end

  test "stock cannot be negative" do
    @item.stock = -1
    assert_not @item.valid?
  end

  test "stock_available? method works correctly" do
    assert @item.stock_available?(5)
    assert_not @item.stock_available?(15)
  end
end
