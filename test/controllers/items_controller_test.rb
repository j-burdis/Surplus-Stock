require "test_helper"

class ItemsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:alice)
    @item = items(:table_lamp)
  end

  test "should get index" do
    get items_url
    assert_response :success
  end

  test "should get show" do
    get item_url(@item)
    assert_response :success
  end

  test "should return 404 for non-existent item" do
    get item_url(id: -1)
    assert_response :not_found
  end
end
