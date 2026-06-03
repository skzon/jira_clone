ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Suppress noisy mailer delivery in tests
    setup { ActionMailer::Base.deliveries.clear }
  end
end

# Devise sign-in helper for controller / integration tests
module AuthHelpers
  def sign_in_as(user, password: "password123")
    post user_session_path, params: {
      user: { email: user.email, password: password }
    }
  end
end

class ActionDispatch::IntegrationTest
  include AuthHelpers
end
