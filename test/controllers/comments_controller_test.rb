require "test_helper"

class CommentsControllerTest < ActionDispatch::IntegrationTest
  def alice         = users(:alice)
  def bob           = users(:bob)
  def open_task     = tasks(:open_task)
  def first_comment = comments(:first_comment)

  # ---------------------------------------------------------------------------
  # create
  # ---------------------------------------------------------------------------
  test "member can post a comment" do
    sign_in_as alice
    assert_difference "Comment.count", 1 do
      post task_comments_path(open_task), params: { comment: { body: "My two cents." } }
    end
    assert_redirected_to task_path(open_task, anchor: "comment-#{Comment.last.id}")
    assert_equal alice, Comment.last.user
  end

  test "non-member cannot post a comment" do
    outsider = User.create!(email: "spy@example.com", password: "password123")
    sign_in_as outsider
    assert_no_difference "Comment.count" do
      post task_comments_path(open_task), params: { comment: { body: "Sneaky comment." } }
    end
    assert_redirected_to projects_path
  end

  test "create with blank body is rejected" do
    sign_in_as alice
    assert_no_difference "Comment.count" do
      post task_comments_path(open_task), params: { comment: { body: "" } }
    end
    assert_redirected_to task_path(open_task)
    assert flash[:alert].present?
  end

  # ---------------------------------------------------------------------------
  # destroy
  # ---------------------------------------------------------------------------
  test "user can delete their own comment" do
    sign_in_as bob  # bob wrote first_comment
    assert_difference "Comment.count", -1 do
      delete task_comment_path(open_task, first_comment)
    end
    assert_redirected_to task_path(open_task)
  end

  test "user cannot delete someone else's comment" do
    sign_in_as alice  # alice did NOT write first_comment
    assert_no_difference "Comment.count" do
      delete task_comment_path(open_task, first_comment)
    end
    assert_redirected_to task_path(open_task)
    assert_match /own comments/, flash[:alert]
  end
end
