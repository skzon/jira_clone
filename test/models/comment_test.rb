require "test_helper"

class CommentTest < ActiveSupport::TestCase
  def first_comment = comments(:first_comment)
  def open_task     = tasks(:open_task)
  def alice         = users(:alice)
  def bob           = users(:bob)

  # ---------------------------------------------------------------------------
  # Validations
  # ---------------------------------------------------------------------------
  test "valid comment is saved" do
    comment = Comment.new(body: "Looks good!", task: open_task, user: alice)
    assert comment.valid?, comment.errors.full_messages.to_sentence
  end

  test "invalid without body" do
    comment = Comment.new(task: open_task, user: alice)
    assert_not comment.valid?
    assert_includes comment.errors[:body], "can't be blank"
  end

  test "invalid without task" do
    comment = Comment.new(body: "Hi", user: alice)
    assert_not comment.valid?
  end

  test "invalid without user" do
    comment = Comment.new(body: "Hi", task: open_task)
    assert_not comment.valid?
  end

  test "body length cap is 5000 characters" do
    comment = Comment.new(body: "A" * 5_001, task: open_task, user: alice)
    assert_not comment.valid?
  end

  # ---------------------------------------------------------------------------
  # Associations
  # ---------------------------------------------------------------------------
  test "belongs to task" do
    assert_equal open_task, first_comment.task
  end

  test "belongs to user" do
    assert_equal bob, first_comment.user
  end
end
