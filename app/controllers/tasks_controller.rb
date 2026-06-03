class TasksController < AuthenticatedController
  before_action :set_project,  only: [ :new, :create ]
  before_action :set_task,     only: [ :show, :edit, :update, :destroy ]
  before_action :authorize!

  def new
    @task = @project.tasks.build
  end

  def create
    @task = @project.tasks.build(task_params)
    @task.reporter = current_user

    if @task.save
      attach_files
      redirect_to task_path(@task), notice: t("flash.task_created")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @comment = Comment.new
  end

  def edit
  end

  def update
    if @task.update(task_params)
      attach_files
      redirect_to task_path(@task), notice: t("flash.task_updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    project = @task.project
    @task.destroy
    redirect_to project_path(project), notice: t("flash.task_deleted")
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_task
    @task = Task.includes(:project, :assignee, :reporter, comments: :user)
                .find(params[:id])
    @project = @task.project
  end

  def authorize!
    require_project_member!(@project)
  end

  def attach_files
    files = Array(params.dig(:task, :attachments)).compact_blank
    @task.attachments.attach(files) if files.any?
  end

  def task_params
    params.require(:task).permit(:title, :description, :status, :assignee_id)
  end
end
