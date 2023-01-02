require 'test_helper'


class RegistrationsControllerTest < ActionDispatch::IntegrationTest

  test "should create member" do
    assert_difference 'Member.count' do
      post user_registration_path, params:{ user: {email:"test@gmail.com", password: "123456", password_confirmation: "123456"}, tenant: { name: "Test", plan: "free"} }
      byebug
    end
  end
end
