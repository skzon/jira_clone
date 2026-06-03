require "test_helper"

class ProjectTest < ActiveSupport::TestCase
  def alpha = projects(:alpha)
  def alice = users(:alice)
  def bob   = users(:bob)

  # ---------------------------------------------------------------------------
  # Validations
  # ---------------------------------------------------------------------------
  test "valid project is saved" do
    project = Project.new(name: "New Project", description: "Desc", creator: alice)
    assert project.valid?, project.errors.full_messages.to_sentence
  end

  test "invalid without name" do
    project = Project.new(description: "Desc", creator: alice)
    assert_not project.valid?
    assert_includes project.errors[:name], "can't be blank"
  end

  test "invalid without description" do
    project = Project.new(name: "No Desc", creator: alice)
    assert_not project.valid?
    assert_includes project.errors[:description], "can't be blank"
  end

  test "invalid with unknown status" do
    project = Project.new(name: "X", description: "Y", status: "flying", creator: alice)
    assert_not project.valid?
  end

  test "name length cap is 80 characters" do
    project = Project.new(name: "A" * 81, description: "Desc", creator: alice)
    assert_not project.valid?
  end

  test "defaults status to active" do
    project = Project.new(name: "No status", description: "Desc", creator: alice)
    project.valid?
    assert_equal "active", project.status
  end

  # ---------------------------------------------------------------------------
  # Associations
  # ---------------------------------------------------------------------------
  test "has many project_members" do
    assert alpha.project_members.exists?(user: alice)
  end

  test "has many members through project_members" do
    assert_includes alpha.members, alice
    assert_includes alpha.members, bob
  end

  test "has many tasks" do
    assert_includes alpha.tasks, tasks(:open_task)
  end

  # ---------------------------------------------------------------------------
  # Instance methods
  # ---------------------------------------------------------------------------
  test "member? returns true for project members" do
    assert alpha.member?(alice)
    assert alpha.member?(bob)
  end

  test "member? returns false for non-members" do
    outsider = User.create!(email: "outsider@example.com", password: "password123")
    assert_not alpha.member?(outsider)
  end

  test "member? returns false for nil" do
    assert_not alpha.member?(nil)
  end

  # ---------------------------------------------------------------------------
  # Callbacks
  # ---------------------------------------------------------------------------
  test "creator is automatically added as member on create" do
    outsider = User.create!(email: "creator@example.com", password: "password123")
    project = Project.create!(name: "Auto-member", description: "Test", creator: outsider)
    assert project.member?(outsider)
  end
end
