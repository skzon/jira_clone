require "test_helper"

class ProjectMemberTest < ActiveSupport::TestCase
  def alice = users(:alice)
  def bob   = users(:bob)
  def alpha = projects(:alpha)
  def beta  = projects(:beta)

  # ---------------------------------------------------------------------------
  # Validations
  # ---------------------------------------------------------------------------
  test "valid project_member is saved" do
    outsider = User.create!(email: "newbie@example.com", password: "password123")
    pm = ProjectMember.new(user: outsider, project: alpha)
    assert pm.valid?, pm.errors.full_messages.to_sentence
  end

  test "prevents duplicate memberships" do
    duplicate = ProjectMember.new(user: alice, project: alpha)
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:user_id], "is already a member of this project"
  end

  test "same user can belong to different projects" do
    pm = ProjectMember.new(user: alice, project: beta)
    assert pm.valid?
  end

  # ---------------------------------------------------------------------------
  # Associations
  # ---------------------------------------------------------------------------
  test "belongs to user" do
    pm = project_members(:alice_alpha)
    assert_equal alice, pm.user
  end

  test "belongs to project" do
    pm = project_members(:alice_alpha)
    assert_equal alpha, pm.project
  end

  # ---------------------------------------------------------------------------
  # Callbacks
  # ---------------------------------------------------------------------------
  test "removing member nullifies their task assignments in that project" do
    # bob is assigned to open_task in alpha
    assert_equal bob, tasks(:open_task).reload.assignee

    project_members(:bob_alpha).destroy

    assert_nil tasks(:open_task).reload.assignee
  end
end
