require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  def alice = users(:alice)

  test "index renders landing page for guests" do
    get root_path
    assert_response :success
    assert_select "a", text: /Get started/
  end

  test "index renders dashboard for signed-in users" do
    sign_in_as alice
    get root_path
    assert_response :success
    assert_select "h1", text: /Welcome back/
  end
end
