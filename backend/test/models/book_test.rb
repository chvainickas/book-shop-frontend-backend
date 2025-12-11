require "test_helper"

class BookTest < ActiveSupport::TestCase
  def setup
    @category = Category.create!(name: "Fiction")
    @book = Book.new(
      title: "Test Book",
      author: "Test Author",
      price: 19.99,
      stock: 10,
      description: "A test book description",
      category: @category
    )
  end

  # Validation Tests
  test "should be valid with valid attributes" do
    assert @book.valid?
  end

  test "should require title" do
    @book.title = nil
    assert_not @book.valid?
    assert_includes @book.errors[:title], "can't be blank"
  end

  test "should require author" do
    @book.author = nil
    assert_not @book.valid?
    assert_includes @book.errors[:author], "can't be blank"
  end

  test "should require price" do
    @book.price = nil
    assert_not @book.valid?
    assert_includes @book.errors[:price], "can't be blank"
  end

  test "should require description" do
    @book.description = nil
    assert_not @book.valid?
    assert_includes @book.errors[:description], "can't be blank"
  end

  test "should validate stock is not negative" do
    @book.stock = -1
    assert_not @book.valid?
    assert_includes @book.errors[:stock], "must be greater than or equal to 0"
  end

  test "should allow stock of zero" do
    @book.stock = 0
    assert @book.valid?
  end

  # Association Tests
  test "should belong to category" do
    assert_respond_to @book, :category
  end

  test "should have many cart_items" do
    assert_respond_to @book, :cart_items
  end

  test "should have many order_items" do
    assert_respond_to @book, :order_items
  end

  test "should have many wishlist_items" do
    assert_respond_to @book, :wishlist_items
  end

  test "category can be optional" do
    @book.category = nil
    assert @book.valid?
  end

  # Method Tests
  test "in_stock? returns true when stock is positive" do
    @book.stock = 5
    assert @book.in_stock?
  end

  test "in_stock? returns false when stock is zero" do
    @book.stock = 0
    assert_not @book.in_stock?
  end

  # Search Scope Tests
  test "search scope finds books by title" do
    @book.save!
    results = Book.search("Test Book")
    assert_includes results, @book
  end

  test "search scope finds books by author" do
    @book.save!
    results = Book.search("Test Author")
    assert_includes results, @book
  end

  test "search scope finds books by description" do
    @book.save!
    results = Book.search("test book description")
    assert_includes results, @book
  end

  test "search scope returns all books when query is blank" do
    @book.save!
    results = Book.search("")
    assert_equal Book.count, results.count
  end

  test "search scope returns all books when query is nil" do
    @book.save!
    results = Book.search(nil)
    assert_equal Book.count, results.count
  end
end
