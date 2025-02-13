require "test_helper"

class WishlistTest < ActiveSupport::TestCase
  def setup
    @user = users(:alice)
    @wishlist = @user.wishlist
  end

  test "wishlist is automatically created with user" do
    new_user = User.create!(
      email: "test@example.com",
      password: "password",
      name: "Test User"
    )
    assert new_user.wishlist.present?, "Wishlist should be automatically created with user"
  end

  test "wishlist belongs to user" do
    assert_equal @user, @wishlist.user
  end

  test "wishlist items are destroyed with wishlist" do
    @wishlist.wishlist_items.create!(item: items(:table_lamp))

    assert_equal 1, @wishlist.wishlist_items.count

    assert_difference("WishlistItem.count", -1) do
      @wishlist.destroy
    end
  end
end
