require "test_helper"

class OrdersTest < ActionDispatch::IntegrationTest
  # index tests
  test "should get all orders for authenticated user" do
    get "/api/v1/orders", headers: auth_headers(users(:customer)), as: :json

    assert_response :success
    json = JSON.parse(response.body)
    assert json["orders"].is_a?(Array)
  end

  test "should not get orders without authentication" do
    get "/api/v1/orders", as: :json

    assert_response :unauthorized
  end

  # show tests
  test "should get single order for owner" do
    get "/api/v1/orders/#{orders(:customer_order).id}",
      headers: auth_headers(users(:customer)), as: :json

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal orders(:customer_order).id, json["order"]["id"]
  end

  test "should not get another users order" do
    get "/api/v1/orders/#{orders(:customer_order).id}",
      headers: auth_headers(users(:admin)), as: :json

    assert_response :not_found
  end

  # create order tests
  test "should create order from cart" do
    # customer has items in cart via fixtures
    assert_difference("Order.count", 1) do
      post "/api/v1/orders", headers: auth_headers(users(:customer)), as: :json
    end

    assert_response :created
    json = JSON.parse(response.body)
    assert_equal "Order placed successfully!", json["message"]
    assert json["order"]["id"].present?
  end

  test "should not create order with empty cart" do
    # admin has empty cart
    assert_no_difference("Order.count") do
      post "/api/v1/orders", headers: auth_headers(users(:admin)), as: :json
    end

    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert_equal "Your cart is empty", json["error"]
  end

  test "should reduce book stock after order" do
    book = books(:in_stock_book)
    initial_stock = book.stock

    post "/api/v1/orders", headers: auth_headers(users(:customer)), as: :json

    assert_response :created
    book.reload
    assert book.stock < initial_stock
  end

  test "should clear cart after order" do
    post "/api/v1/orders", headers: auth_headers(users(:customer)), as: :json

    assert_response :created

    # verify cart is empty
    get "/api/v1/cart", headers: auth_headers(users(:customer)), as: :json
    json = JSON.parse(response.body)
    assert_equal 0, json["cart"]["items"].length
  end

  test "should not create order without authentication" do
    assert_no_difference("Order.count") do
      post "/api/v1/orders", as: :json
    end

    assert_response :unauthorized
  end
end
