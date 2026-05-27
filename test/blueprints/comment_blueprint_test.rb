require "test_helper"

class CommentBlueprintTest < ActiveSupport::TestCase
  def first_comment = comments(:first_comment)
  def bob           = users(:bob)

  test "default view includes body, task_id, timestamps, and author" do
    result = CommentBlueprint.render_as_hash(first_comment)

    assert_equal first_comment.id,      result[:id]
    assert_equal first_comment.body,    result[:body]
    assert_equal first_comment.task_id, result[:task_id]
    assert_equal bob.email,             result.dig(:user, :email)
    assert result[:created_at].present?
  end

  test "render returns valid JSON" do
    json   = CommentBlueprint.render(first_comment)
    parsed = JSON.parse(json)
    assert_equal first_comment.body, parsed["body"]
  end
end
