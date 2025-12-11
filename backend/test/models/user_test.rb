require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(
      email: "test@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
  end

  # Validation Tests
  test "should be valid with valid attributes" do
    assert @user.valid?
  end

  test "should require email" do
    @user.email = nil
    assert_not @user.valid?
    assert_includes @user.errors[:email], "can't be blank"
  end

  test "should require unique email" do
    @user.save!
    duplicate_user = User.new(
      email: "test@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
    assert_not duplicate_user.valid?
    assert_includes duplicate_user.errors[:email], "has already been taken"
  end

  test "should validate email format" do
    invalid_emails = ["invalid", "invalid@", "@example.com"]
    invalid_emails.each do |invalid_email|
      @user.email = invalid_email
      assert_not @user.valid?, "#{invalid_email} should be invalid"
    end
  end

  test "should accept valid email formats" do
    valid_emails = ["user@example.com", "USER@foo.COM", "a_user@foo.bar.org"]
    valid_emails.each do |valid_email|
      @user.email = valid_email
      assert @user.valid?, "#{valid_email} should be valid"
    end
  end

  test "should save email in lowercase" do
    @user.email = "TEST@EXAMPLE.COM"
    @user.save!
    assert_equal "test@example.com", @user.reload.email
  end

  test "should require minimum password length" do
    @user.password = @user.password_confirmation = "short"
    assert_not @user.valid?
    assert_includes @user.errors[:password], "is too short (minimum is 6 characters)"
  end

  test "should require password confirmation to match" do
    @user.password = "password123"
    @user.password_confirmation = "different"
    assert_not @user.valid?
    assert_includes @user.errors[:password_confirmation], "doesn't match Password"
  end

  # Association Tests
  test "should have one cart" do
    assert_respond_to @user, :cart
  end

  test "should have many orders" do
    assert_respond_to @user, :orders
  end

  test "should have many wishlist_items" do
    assert_respond_to @user, :wishlist_items
  end

  # Admin Tests
  test "should not be admin by default" do
    assert_not @user.admin?
  end

  test "can be set as admin" do
    @user.admin = true
    assert @user.admin?
  end

  # Authentication Tests
  test "authenticated? should return true for correct password" do
    @user.save!
    assert @user.authenticate("password123")
  end

  test "authenticated? should return false for incorrect password" do
    @user.save!
    assert_not @user.authenticate("wrong")
  end

  # Dependent Destroy Tests
  test "destroying user should destroy associated cart" do
    @user.save!
    # Cart is automatically created in after_create callback
    assert_not_nil @user.cart

    assert_difference "Cart.count", -1 do
      @user.destroy
    end
  end

  test "destroying user should destroy associated wishlist_items" do
    @user.save!
    category = Category.create!(name: "Fiction")
    book = Book.create!(
      title: "Test",
      author: "Author",
      price: 10,
      stock: 5,
      description: "Test",
      category: category
    )
    WishlistItem.create!(user: @user, book: book)

    assert_difference "WishlistItem.count", -1 do
      @user.destroy
    end
  end
end
