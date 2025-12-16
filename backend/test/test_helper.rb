ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end

# helper module for integration tests that need jwt authentication
module AuthenticationHelper
  # generate jwt token for a user
  def token_for(user)
    JsonWebToken.encode(user_id: user.id)
  end

  # return authorization header hash for a user
  def auth_headers(user)
    { "Authorization" => "Bearer #{token_for(user)}" }
  end
end

class ActionDispatch::IntegrationTest
  include AuthenticationHelper
end
