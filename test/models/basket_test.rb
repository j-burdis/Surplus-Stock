require "test_helper"

class BasketTest < ActiveSupport::TestCase
  def setup
    @user = users(:alice)
    @basket = @user.basket
  end

  test "basket is automatically created with user" do
    new_user = User.create!(
      email: "test@example.co.uk",
      password: "password",
      name: "Test User"
    )
    assert new_user.basket.present?, "Basket should be automatically created with user"
  end

  test "basket belongs to a user" do
    assert_equal @user, @basket.user
  end
end
