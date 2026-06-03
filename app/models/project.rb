class Project < ApplicationRecord
  STATUSES = %w[active on_hold completed].freeze

  searchkick word_middle: [ :name, :description ],
             filterable:  [ :member_ids ]

  belongs_to :creator, class_name: "User", foreign_key: :user_id, optional: true, inverse_of: :created_projects

  has_many :project_members, dependent: :destroy
  has_many :members, through: :project_members, source: :user
  has_many :tasks, dependent: :destroy

  validates :name, presence: true, length: { maximum: 80 }
  validates :description, presence: true
  validates :status, inclusion: { in: STATUSES }, allow_blank: true

  before_validation :default_status
  after_create :add_creator_as_member

  def search_data
    {
      name:        name,
      description: description,
      status:      status,
      member_ids:  project_members.pluck(:user_id),
      updated_at:  updated_at,
      created_at:  created_at
    }
  end

  def status_label
    (status.presence || "active").humanize
  end

  def member?(user)
    return false if user.blank?
    project_members.exists?(user_id: user.id)
  end

  # Cached member count — avoids a COUNT query on every page render.
  # Cache is invalidated when any ProjectMember for this project changes.
  def cached_member_count
    Rails.cache.fetch([ "project/member_count", id, project_members.maximum(:updated_at) ], expires_in: 1.hour) do
      project_members.count
    end
  end

  private

  def default_status
    self.status = "active" if status.blank?
  end

  def add_creator_as_member
    return if creator.blank?
    project_members.find_or_create_by!(user: creator)
  end
end
