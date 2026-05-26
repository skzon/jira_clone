require "test_helper"

class UserTest < ActiveSupport::TestCase
  # ---------------------------------------------------------------------------
  # Fixtures
  # ---------------------------------------------------------------------------
  def alice = users(:alice)
  def bob   = users(:bob)

  # ---------------------------------------------------------------------------
  # Validations
  # ---------------------------------------------------------------------------
  test "valid user is saved" do
    user = User.new(email: "new@example.com", password: "password123")
    assert user.valid?, user.errors.full_messages.to_sentence
  end

  test "invalid without email" do
    user = User.new(password: "password123")
    assert_not user.valid?
    assert_includes user.errors[:email], "can't be blank"
  end

  test "invalid with duplicate email" do
    duplicate = User.new(email: alice.email, password: "password123")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:email], "has already been taken"
  end

  test "invalid with short password" do
    user = User.new(email: "new2@example.com", password: "abc")
    assert_not user.valid?
  end

  # ---------------------------------------------------------------------------
  # Associations
  # ---------------------------------------------------------------------------
  test "has many project_members" do
    assert_respond_to alice, :project_members
  end

  test "has many projects through project_members" do
    assert_includes alice.projects, projects(:alpha)
  end

  test "has many reported_tasks" do
    assert_includes alice.reported_tasks, tasks(:open_task)
  end

  test "has many assigned_tasks" do
    assert_includes bob.assigned_tasks, tasks(:open_task)
  end

  test "has many comments" do
    assert_includes bob.comments, comments(:first_comment)
  end

  # ---------------------------------------------------------------------------
  # Instance methods
  # ---------------------------------------------------------------------------
  test "display_name returns email prefix" do
    assert_equal "alice", alice.display_name
  end
end
