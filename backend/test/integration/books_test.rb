require "test_helper"

class BooksTest < ActionDispatch::IntegrationTest
  # index tests
  test "should get all books without authentication" do
    get "/api/v1/books", as: :json

    assert_response :success
    json = JSON.parse(response.body)
    assert json["books"].is_a?(Array)
    assert json["pagination"].present?
  end

  test "should filter books by category" do
    get "/api/v1/books", params: { category_id: categories(:fiction).id }, as: :json

    assert_response :success
    json = JSON.parse(response.body)
    json["books"].each do |book|
      assert_equal categories(:fiction).id, book["category"]["id"]
    end
  end

  test "should search books by query" do
    get "/api/v1/books", params: { query: "Test Book One" }, as: :json

    assert_response :success
    json = JSON.parse(response.body)
    assert json["books"].any? { |b| b["title"] == "Test Book One" }
  end

  # show tests
  test "should get single book without authentication" do
    get "/api/v1/books/#{books(:in_stock_book).id}", as: :json

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal "Test Book One", json["book"]["title"]
    assert_equal "Test Author", json["book"]["author"]
  end

  test "should return 404 for non-existent book" do
    get "/api/v1/books/999999", as: :json

    assert_response :not_found
  end

  # create tests (admin only)
  test "admin should create book" do
    assert_difference("Book.count", 1) do
      post "/api/v1/books", params: {
        book: {
          title: "New Book",
          author: "New Author",
          price: 24.99,
          stock: 15,
          description: "A brand new book",
          category_id: categories(:fiction).id
        }
      }, headers: auth_headers(users(:admin)), as: :json
    end

    assert_response :created
    json = JSON.parse(response.body)
    assert_equal "New Book", json["book"]["title"]
  end

  test "non-admin should not create book" do
    assert_no_difference("Book.count") do
      post "/api/v1/books", params: {
        book: {
          title: "New Book",
          author: "New Author",
          price: 24.99,
          stock: 15,
          description: "A brand new book"
        }
      }, headers: auth_headers(users(:customer)), as: :json
    end

    assert_response :forbidden
  end

  test "should reject book creation without authentication" do
    assert_no_difference("Book.count") do
      post "/api/v1/books", params: {
        book: {
          title: "New Book",
          author: "New Author",
          price: 24.99,
          stock: 15,
          description: "A brand new book"
        }
      }, as: :json
    end

    assert_response :unauthorized
  end

  # update tests (admin only)
  test "admin should update book" do
    patch "/api/v1/books/#{books(:in_stock_book).id}", params: {
      book: { title: "Updated Title" }
    }, headers: auth_headers(users(:admin)), as: :json

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal "Updated Title", json["book"]["title"]
  end

  test "non-admin should not update book" do
    patch "/api/v1/books/#{books(:in_stock_book).id}", params: {
      book: { title: "Updated Title" }
    }, headers: auth_headers(users(:customer)), as: :json

    assert_response :forbidden
  end

  # delete tests (admin only)
  test "admin should delete book" do
    assert_difference("Book.count", -1) do
      delete "/api/v1/books/#{books(:expensive_book).id}",
        headers: auth_headers(users(:admin)), as: :json
    end

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal "Book was successfully deleted", json["message"]
  end

  test "non-admin should not delete book" do
    assert_no_difference("Book.count") do
      delete "/api/v1/books/#{books(:in_stock_book).id}",
        headers: auth_headers(users(:customer)), as: :json
    end

    assert_response :forbidden
  end
end
