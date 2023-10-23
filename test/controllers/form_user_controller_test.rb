require "test_helper"

class FormUserControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get form_user_new_url
    assert_response :success
  end

  test "should get create" do
    get form_user_create_url
    assert_response :success
  end
end
