class Task < ApplicationRecord
  STATUSES = %w[to_do in_progress done].freeze

  searchkick word_middle: [ :title, :description ],
             text_middle: [ :assignee_email, :project_name ],
             filterable:  [ :status, :project_id ]

  belongs_to :project
  belongs_to :reporter, class_name: "User", optional: true
  belongs_to :assignee, class_name: "User", optional: true

  has_many :comments, -> { order(created_at: :asc) }, dependent: :destroy
  has_many_attached :attachments

  validates :title, presence: true, length: { maximum: 120 }
  validates :status, inclusion: { in: STATUSES }
  validate  :attachments_size_within_limit

  before_validation :default_status

  after_create_commit  :notify_assignment_on_create
  after_update_commit  :notify_assignment_on_change
  after_update_commit  :notify_general_update

  scope :recent, -> { order(updated_at: :desc) }

  ATTACHMENT_MAX_BYTES = 10.megabytes

  def search_data
    {
      title:          title,
      description:    description,
      status:         status,
      project_id:     project_id,
      project_name:   project.name,
      assignee_email: assignee&.email,
      updated_at:     updated_at,
      created_at:     created_at
    }
  end

  def status_label
    status.to_s.humanize
  end

  def participants
    [ assignee, reporter ].compact.uniq
  end

  private

  def default_status
    self.status = "to_do" if status.blank?
  end

  def attachments_size_within_limit
    attachments.each do |att|
      if att.byte_size > ATTACHMENT_MAX_BYTES
        errors.add(:attachments, "#{att.filename} is too large (max #{ATTACHMENT_MAX_BYTES / 1.megabyte} MB)")
      end
    end
  end

  def notify_assignment_on_create
    return if assignee.blank?
    return if assignee == Current.actor
    TaskMailer.assigned(self, Current.actor).deliver_later
  end

  def notify_assignment_on_change
    return unless saved_change_to_assignee_id?
    return if assignee.blank?
    return if assignee == Current.actor
    TaskMailer.assigned(self, Current.actor).deliver_later
  end

  def notify_general_update
    return unless saved_changes.keys.intersect?(%w[title description status])
    recipients = participants - [ Current.actor ].compact
    return if recipients.empty?
    TaskMailer.updated(self, Current.actor, saved_changes.slice("title", "description", "status")).deliver_later
  end
end
