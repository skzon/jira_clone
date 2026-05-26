require "test_helper"

class ProjectsControllerTest < ActionDispatch::IntegrationTest
  def alice = users(:alice)
  def bob   = users(:bob)
  def alpha = projects(:alpha)

  # ---------------------------------------------------------------------------
  # Authentication guard
  # ---------------------------------------------------------------------------
  test "index redirects to login when not signed in" do
    get projects_path
    assert_redirected_to new_user_session_path
  end

  test "show redirects to login when not signed in" do
    get project_path(alpha)
    assert_redirected_to new_user_session_path
  end

  # ---------------------------------------------------------------------------
  # index
  # ---------------------------------------------------------------------------
  test "index lists projects the current user is a member of" do
    sign_in_as alice
    get projects_path
    assert_response :success
    assert_select "h5", text: alpha.name
  end

  # ---------------------------------------------------------------------------
  # show
  # ---------------------------------------------------------------------------
  test "show renders project page for member" do
    sign_in_as alice
    get project_path(alpha)
    assert_response :success
    assert_select "h1", text: /#{alpha.name}/
  end

  test "show denies access to non-members" do
    outsider = User.create!(email: "outsider@example.com", password: "password123")
    sign_in_as outsider
    get project_path(alpha)
    assert_redirected_to projects_path
    assert_match /don't have access/, flash[:alert]
  end

  # ---------------------------------------------------------------------------
  # new / create
  # ---------------------------------------------------------------------------
  test "new renders form for signed-in user" do
    sign_in_as alice
    get new_project_path
    assert_response :success
    assert_select "form"
  end

  test "create saves project and adds creator as member" do
    sign_in_as alice
    assert_difference "Project.count", 1 do
      post projects_path, params: {
        project: { name: "New Venture", description: "Something fresh", status: "active" }
      }
    end
    project = Project.last
    assert_redirected_to project_path(project)
    assert project.member?(alice), "creator should be a member automatically"
  end

  test "create with invalid params re-renders the form" do
    sign_in_as alice
    assert_no_difference "Project.count" do
      post projects_path, params: { project: { name: "", description: "" } }
    end
    assert_response :unprocessable_entity
  end

  # ---------------------------------------------------------------------------
  # edit / update
  # ---------------------------------------------------------------------------
  test "edit renders form for project member" do
    sign_in_as alice
    get edit_project_path(alpha)
    assert_response :success
  end

  test "update saves changes" do
    sign_in_as alice
    patch project_path(alpha), params: {
      project: { name: "Alpha Renamed", description: alpha.description, status: alpha.status }
    }
    assert_redirected_to project_path(alpha)
    assert_equal "Alpha Renamed", alpha.reload.name
  end

  test "update with invalid params re-renders form" do
    sign_in_as alice
    patch project_path(alpha), params: { project: { name: "", description: "" } }
    assert_response :unprocessable_entity
  end

  # ---------------------------------------------------------------------------
  # destroy
  # ---------------------------------------------------------------------------
  test "destroy deletes the project" do
    sign_in_as alice
    assert_difference "Project.count", -1 do
      delete project_path(alpha)
    end
    assert_redirected_to projects_path
  end
end
