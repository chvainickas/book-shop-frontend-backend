require "test_helper"

class AuthenticationTest < ActionDispatch::IntegrationTest
  # login tests
  test "should login with valid credentials" do
    post "/api/v1/auth/login", params: {
      user: { email: "customer@test.com", password: "password123" }
    }, as: :json

    assert_response :success
    json = JSON.parse(response.body)
    assert json["token"].present?
    assert_equal "customer@test.com", json["user"]["email"]
    assert_equal "Test Customer", json["user"]["name"]
  end

  test "should reject login with invalid password" do
    post "/api/v1/auth/login", params: {
      user: { email: "customer@test.com", password: "wrongpassword" }
    }, as: :json

    assert_response :unauthorized
    json = JSON.parse(response.body)
    assert_equal "Invalid email or password", json["error"]
  end

  test "should reject login with non-existent email" do
    post "/api/v1/auth/login", params: {
      user: { email: "nonexistent@test.com", password: "password123" }
    }, as: :json

    assert_response :unauthorized
  end

  # signup tests
  test "should create new user with valid data" do
    assert_difference("User.count", 1) do
      post "/api/v1/auth/signup", params: {
        user: {
          name: "New User",
          email: "newuser@test.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }, as: :json
    end

    assert_response :created
    json = JSON.parse(response.body)
    assert json["token"].present?
    assert_equal "newuser@test.com", json["user"]["email"]
  end

  test "should reject signup with mismatched passwords" do
    assert_no_difference("User.count") do
      post "/api/v1/auth/signup", params: {
        user: {
          name: "New User",
          email: "newuser@test.com",
          password: "password123",
          password_confirmation: "differentpassword"
        }
      }, as: :json
    end

    assert_response :unprocessable_entity
  end

  test "should reject signup with duplicate email" do
    assert_no_difference("User.count") do
      post "/api/v1/auth/signup", params: {
        user: {
          name: "Another User",
          email: "customer@test.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }, as: :json
    end

    assert_response :unprocessable_entity
  end

  # me endpoint tests
  test "should return current user when authenticated" do
    get "/api/v1/auth/me", headers: auth_headers(users(:customer)), as: :json

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal "customer@test.com", json["user"]["email"]
  end

  test "should reject me request without token" do
    get "/api/v1/auth/me", as: :json

    assert_response :unauthorized
  end
end
