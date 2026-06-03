require "test_helper"

class TaskTest < ActiveSupport::TestCase
  def open_task = tasks(:open_task)
  def alice     = users(:alice)
  def bob       = users(:bob)
  def alpha     = projects(:alpha)

  # ---------------------------------------------------------------------------
  # Validations
  # ---------------------------------------------------------------------------
  test "valid task is saved" do
    task = Task.new(title: "New task", project: alpha, reporter: alice)
    assert task.valid?, task.errors.full_messages.to_sentence
  end

  test "invalid without title" do
    task = Task.new(project: alpha, reporter: alice)
    assert_not task.valid?
    assert_includes task.errors[:title], "can't be blank"
  end

  test "title length cap is 120 characters" do
    task = Task.new(title: "A" * 121, project: alpha, reporter: alice)
    assert_not task.valid?
  end

  test "invalid with unknown status" do
    task = Task.new(title: "X", project: alpha, status: "unknown")
    assert_not task.valid?
  end

  test "defaults status to to_do" do
    task = Task.new(title: "No status", project: alpha)
    task.valid?
    assert_equal "to_do", task.status
  end

  # ---------------------------------------------------------------------------
  # Associations
  # ---------------------------------------------------------------------------
  test "belongs to project" do
    assert_equal alpha, open_task.project
  end

  test "belongs to reporter" do
    assert_equal alice, open_task.reporter
  end

  test "belongs to assignee (optional)" do
    assert_equal bob, open_task.assignee
  end

  test "has many comments" do
    assert_includes open_task.comments, comments(:first_comment)
  end

  test "assignee is optional" do
    task = Task.new(title: "Unassigned", project: alpha)
    assert task.valid?
  end

  # ---------------------------------------------------------------------------
  # Instance methods
  # ---------------------------------------------------------------------------
  test "status_label humanises status" do
    assert_equal "To do", open_task.status_label
  end

  test "participants includes reporter and assignee" do
    assert_includes open_task.participants, alice
    assert_includes open_task.participants, bob
  end

  test "participants excludes nils" do
    task = tasks(:in_progress_task)  # no assignee
    assert_not_includes task.participants, nil
  end

  test "participants are unique" do
    task = Task.new(title: "Same person", project: alpha,
                    reporter: alice, assignee: alice)
    assert_equal 1, task.participants.size
  end

  # ---------------------------------------------------------------------------
  # STATUSES constant
  # ---------------------------------------------------------------------------
  test "STATUSES includes expected values" do
    assert_includes Task::STATUSES, "to_do"
    assert_includes Task::STATUSES, "in_progress"
    assert_includes Task::STATUSES, "done"
  end
end
