class ProjectMembersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project
  before_action :authorize!

  def create
    user = User.find_by(id: params[:user_id])

    if user.blank?
      return redirect_to project_path(@project), alert: "Please pick a user to add."
    end

    membership = @project.project_members.find_or_initialize_by(user: user)

    if membership.persisted?
      redirect_to project_path(@project), alert: t("flash.member_added", email: user.email)
    elsif membership.save
      redirect_to project_path(@project), notice: t("flash.member_added", email: user.email)
    else
      redirect_to project_path(@project), alert: membership.errors.full_messages.to_sentence
    end
  end

  def destroy
    membership = @project.project_members.find(params[:id])
    removed_email = membership.user.email
    membership.destroy
    redirect_to project_path(@project), notice: t("flash.member_removed", email: removed_email)
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def authorize!
    require_project_member!(@project)
  end
end
