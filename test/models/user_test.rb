require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup 
    @new_user = User.new(
      email: "test@example.com",
      name: "Test User",
      password: "password",
      password_confirmation: "password"
    )
  end

  test "user is valid" do
    assert @new_user.valid?, "User should be valid with all attributes"
  end

  test "user requires an email address" do
    @new_user.email = nil
    assert_not @new_user.valid?, "User should be invalid without an email"
  end

  test "user requires a password" do
    @new_user.password = nil
    @new_user.password_confirmation = nil
    assert_not @new_user.valid?, "User should be invalid without a password"
  end
end
