class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :project_members, dependent: :destroy
  has_many :projects, through: :project_members

  has_many :created_projects, class_name: "Project",
                              foreign_key: :user_id,
                              dependent: :nullify,
                              inverse_of: :creator

  has_many :reported_tasks, class_name: "Task", foreign_key: :reporter_id, dependent: :nullify
  has_many :assigned_tasks, class_name: "Task", foreign_key: :assignee_id, dependent: :nullify
  has_many :comments, dependent: :destroy

  def display_name
    email.to_s.split("@").first
  end
end
