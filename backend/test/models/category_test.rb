require "test_helper"

class CategoryTest < ActiveSupport::TestCase
  def setup
    @category = Category.new(name: "Fiction")
  end

  # Validation Tests
  test "should be valid with valid attributes" do
    assert @category.valid?
  end

  test "should require name" do
    @category.name = nil
    assert_not @category.valid?
    assert_includes @category.errors[:name], "can't be blank"
  end

  test "should require unique name" do
    @category.save!
    duplicate_category = Category.new(name: "Fiction")
    assert_not duplicate_category.valid?
    assert_includes duplicate_category.errors[:name], "has already been taken"
  end

  # Association Tests
  test "should have many books" do
    assert_respond_to @category, :books
  end

  test "destroying category should nullify books category_id" do
    @category.save!
    book = Book.create!(
      title: "Test Book",
      author: "Test Author",
      price: 19.99,
      stock: 10,
      description: "Test description",
      category: @category
    )

    assert_no_difference "Book.count" do
      @category.destroy
    end

    assert_nil book.reload.category_id
  end
end
