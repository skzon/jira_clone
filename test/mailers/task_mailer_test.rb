require "test_helper"

class TaskMailerTest < ActionMailer::TestCase
  def alice     = users(:alice)
  def bob       = users(:bob)
  def open_task = tasks(:open_task)

  # ---------------------------------------------------------------------------
  # assigned
  # ---------------------------------------------------------------------------
  test "assigned email is sent to the assignee" do
    mail = TaskMailer.assigned(open_task, alice)

    assert_emails 1 do
      mail.deliver_now
    end
  end

  test "assigned email has correct recipient" do
    mail = TaskMailer.assigned(open_task, alice)
    assert_equal [ bob.email ], mail.to
  end

  test "assigned email subject mentions the task title" do
    mail = TaskMailer.assigned(open_task, alice)
    assert_match open_task.title, mail.subject
  end

  test "assigned email body includes the project name" do
    mail = TaskMailer.assigned(open_task, alice)
    assert_match open_task.project.name, mail.body.encoded
  end

  # ---------------------------------------------------------------------------
  # updated
  # ---------------------------------------------------------------------------
  test "updated email is sent when task changes" do
    changes = { "status" => [ "to_do", "in_progress" ] }
    mail = TaskMailer.updated(open_task, alice, changes)

    assert_equal [ bob.email ], mail.to
    assert_match open_task.title, mail.subject
    assert_match "in_progress", mail.body.encoded
  end

  test "updated email is not delivered to the actor" do
    changes = { "status" => [ "to_do", "done" ] }
    mail = TaskMailer.updated(open_task, alice, changes)
    assert_not_includes mail.to, alice.email
  end

  # ---------------------------------------------------------------------------
  # commented
  # ---------------------------------------------------------------------------
  test "commented email is sent to participants except the comment author" do
    comment = comments(:first_comment)  # bob commented
    mail    = TaskMailer.commented(comment)

    assert_equal [ alice.email ], mail.to
    assert_match "New comment", mail.subject
    assert_match comment.body, mail.body.encoded
  end
end
