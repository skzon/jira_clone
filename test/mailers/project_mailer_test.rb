require "test_helper"

class ProjectMailerTest < ActionMailer::TestCase
  def alice = users(:alice)
  def bob   = users(:bob)
  def alpha = projects(:alpha)

  test "added email is sent to the new member" do
    mail = ProjectMailer.added(alpha, bob, alice)

    assert_emails 1 do
      mail.deliver_now
    end
  end

  test "added email recipient is the new member" do
    mail = ProjectMailer.added(alpha, bob, alice)
    assert_equal [ bob.email ], mail.to
  end

  test "added email subject includes the project name" do
    mail = ProjectMailer.added(alpha, bob, alice)
    assert_match alpha.name, mail.subject
  end

  test "added email body includes actor's email" do
    mail = ProjectMailer.added(alpha, bob, alice)
    assert_match alice.email, mail.body.encoded
  end

  test "added email body includes project description" do
    mail = ProjectMailer.added(alpha, bob, alice)
    assert_match alpha.description, mail.body.encoded
  end
end
