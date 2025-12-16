require "test_helper"

class CartsTest < ActionDispatch::IntegrationTest
  # show cart tests
  test "should get cart when authenticated" do
    get "/api/v1/cart", headers: auth_headers(users(:customer)), as: :json

    assert_response :success
    json = JSON.parse(response.body)
    assert json["cart"].present?
    assert json["cart"]["items"].is_a?(Array)
    assert json["cart"]["total"].present?
  end

  test "should not get cart without authentication" do
    get "/api/v1/cart", as: :json

    assert_response :unauthorized
  end

  # add item tests
  test "should add book to cart" do
    assert_difference("CartItem.count", 1) do
      post "/api/v1/cart/items", params: {
        book_id: books(:expensive_book).id,
        quantity: 1
      }, headers: auth_headers(users(:admin)), as: :json
    end

    assert_response :created
    json = JSON.parse(response.body)
    assert_equal "Expensive Book", json["cart_item"]["book"]["title"]
  end

  test "should increase quantity when adding existing book to cart" do
    # customer already has in_stock_book in cart via fixtures
    assert_no_difference("CartItem.count") do
      post "/api/v1/cart/items", params: {
        book_id: books(:in_stock_book).id,
        quantity: 1
      }, headers: auth_headers(users(:customer)), as: :json
    end

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal 3, json["cart_item"]["quantity"] # was 2, now 3
  end

  test "should return 404 when adding non-existent book" do
    post "/api/v1/cart/items", params: {
      book_id: 999999,
      quantity: 1
    }, headers: auth_headers(users(:customer)), as: :json

    assert_response :not_found
  end

  # update item tests
  test "should update cart item quantity" do
    patch "/api/v1/cart/items/#{cart_items(:customer_cart_item).id}", params: {
      quantity: 5
    }, headers: auth_headers(users(:customer)), as: :json

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal 5, json["cart_item"]["quantity"]
  end

  test "should not update other users cart items" do
    patch "/api/v1/cart/items/#{cart_items(:customer_cart_item).id}", params: {
      quantity: 5
    }, headers: auth_headers(users(:admin)), as: :json

    assert_response :not_found
  end

  # remove item tests
  test "should remove item from cart" do
    assert_difference("CartItem.count", -1) do
      delete "/api/v1/cart/items/#{cart_items(:customer_cart_item).id}",
        headers: auth_headers(users(:customer)), as: :json
    end

    assert_response :success
  end

  test "should not remove other users cart items" do
    assert_no_difference("CartItem.count") do
      delete "/api/v1/cart/items/#{cart_items(:customer_cart_item).id}",
        headers: auth_headers(users(:admin)), as: :json
    end

    assert_response :not_found
  end

  # clear cart tests
  test "should clear entire cart" do
    delete "/api/v1/cart", headers: auth_headers(users(:customer)), as: :json

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal "Cart cleared", json["message"]
  end
end
