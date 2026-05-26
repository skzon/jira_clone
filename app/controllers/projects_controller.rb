class ProjectsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project,           only: [ :show, :edit, :update, :destroy ]
  before_action :authorize_project!,    only: [ :show, :edit, :update, :destroy ]

  def index
    @projects = current_user.projects.order(created_at: :desc).distinct
  end

  def show
    @tasks = @project.tasks.recent.includes(:assignee, :reporter)
    @members = @project.members.order(:email)
    @candidate_members = User.where.not(id: @members.select(:id)).order(:email)
  end

  def new
    @project = Project.new
  end

  def create
    @project = Project.new(project_params)
    @project.creator = current_user

    if @project.save
      redirect_to project_path(@project), notice: t("flash.project_created")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @project.update(project_params)
      redirect_to project_path(@project), notice: t("flash.project_updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @project.destroy
    redirect_to projects_path, notice: t("flash.project_deleted")
  end

  private

  def set_project
    @project = Project.find(params[:id])
  end

  def authorize_project!
    require_project_member!(@project)
  end

  def project_params
    params.require(:project).permit(:name, :description, :status)
  end
end
