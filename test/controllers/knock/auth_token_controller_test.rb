require 'test_helper'

module Knock
  class AuthTokenControllerTest < ActionController::TestCase
    setup do
      @routes = Engine.routes
    end

    def user
      @user ||= users(:one)
    end

    test "it's using configured custom exception" do
      assert_equal Knock.not_found_exception_class, Knock::MyCustomException
    end

    test "responds with 404 if user does not exist" do
      post :create, auth: { email: 'wrong@example.net', password: '' }
      assert_response :not_found
    end

    test "responds with 404 if password is invalid" do
      post :create, auth: { email: user.email, password: 'wrong' }
      assert_response :not_found
    end

    test "responds with 201" do
      post :create, auth: { email: user.email, password: 'secret' }
      assert_response :created
    end

    test "allows changing of top level params key" do
      swap_resource(:auth_token) do
        post :create, auth_token: { email: user.email, password: 'secret' }
        assert_response :created
      end
    end

    def swap_resource(value, &block)
      original_value = Knock.resource
      Knock.resource = value
      block.call
      Knock.resource = original_value
    end
  end
end
