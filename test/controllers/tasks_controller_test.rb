require "test_helper"

class TasksControllerTest < ActionDispatch::IntegrationTest
  def alice     = users(:alice)
  def bob       = users(:bob)
  def alpha     = projects(:alpha)
  def open_task = tasks(:open_task)

  # ---------------------------------------------------------------------------
  # Authentication guard
  # ---------------------------------------------------------------------------
  test "new redirects to login when not signed in" do
    get new_project_task_path(alpha)
    assert_redirected_to new_user_session_path
  end

  # ---------------------------------------------------------------------------
  # new / create
  # ---------------------------------------------------------------------------
  test "new renders form for project member" do
    sign_in_as alice
    get new_project_task_path(alpha)
    assert_response :success
    assert_select "form"
  end

  test "non-member cannot access new task form" do
    outsider = User.create!(email: "out@example.com", password: "password123")
    sign_in_as outsider
    get new_project_task_path(alpha)
    assert_redirected_to projects_path
  end

  test "create adds task to project" do
    sign_in_as alice
    assert_difference "Task.count", 1 do
      post project_tasks_path(alpha), params: {
        task: { title: "A brand new task", description: "Details here", status: "to_do" }
      }
    end
    task = Task.last
    assert_equal alice, task.reporter
    assert_redirected_to task_path(task)
  end

  test "create with invalid params re-renders form" do
    sign_in_as alice
    assert_no_difference "Task.count" do
      post project_tasks_path(alpha), params: { task: { title: "" } }
    end
    assert_response :unprocessable_entity
  end

  # ---------------------------------------------------------------------------
  # show
  # ---------------------------------------------------------------------------
  test "show renders task for project member" do
    sign_in_as alice
    get task_path(open_task)
    assert_response :success
    assert_select "h1", text: /#{open_task.title}/
  end

  test "show blocks non-member" do
    outsider = User.create!(email: "out2@example.com", password: "password123")
    sign_in_as outsider
    get task_path(open_task)
    assert_redirected_to projects_path
  end

  # ---------------------------------------------------------------------------
  # edit / update
  # ---------------------------------------------------------------------------
  test "update changes task attributes" do
    sign_in_as alice
    patch task_path(open_task), params: {
      task: { title: "Updated title", description: open_task.description, status: "in_progress" }
    }
    assert_redirected_to task_path(open_task)
    assert_equal "Updated title", open_task.reload.title
    assert_equal "in_progress",   open_task.reload.status
  end

  test "update with invalid params re-renders form" do
    sign_in_as alice
    patch task_path(open_task), params: { task: { title: "" } }
    assert_response :unprocessable_entity
  end

  # ---------------------------------------------------------------------------
  # destroy
  # ---------------------------------------------------------------------------
  test "destroy removes task and redirects to project" do
    sign_in_as alice
    assert_difference "Task.count", -1 do
      delete task_path(open_task)
    end
    assert_redirected_to project_path(alpha)
  end
end
