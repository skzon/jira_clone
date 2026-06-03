class Comment < ApplicationRecord
  belongs_to :task
  belongs_to :user

  validates :body, presence: true, length: { maximum: 5_000 }

  after_create_commit :notify_participants

  private

  def notify_participants
    recipients = (task.participants - [ user ]).uniq
    return if recipients.empty?
    TaskMailer.commented(self).deliver_later
  end
end
