class AttachmentsController < AuthenticatedController
  before_action :set_task
  before_action :authorize!

  def destroy
    attachment = @task.attachments.find(params[:id])
    attachment.purge_later
    redirect_to task_path(@task), notice: "Attachment removed."
  end

  private

  def set_task
    @task = Task.find(params[:task_id])
  end

  def authorize!
    require_project_member!(@task.project)
  end
end
