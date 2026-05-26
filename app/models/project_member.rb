class ProjectMember < ApplicationRecord
  belongs_to :user
  belongs_to :project

  validates :user_id, uniqueness: { scope: :project_id, message: "is already a member of this project" }

  before_destroy :unassign_user_from_project_tasks
  after_create_commit :notify_user_added

  private

  def unassign_user_from_project_tasks
    project.tasks.where(assignee_id: user_id).update_all(assignee_id: nil)
  end

  def notify_user_added
    return if user == Current.actor
    ProjectMailer.added(project, user, Current.actor).deliver_later
  end
end
