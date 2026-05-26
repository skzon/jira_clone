class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_task
  before_action :authorize!
  before_action :set_comment, only: [ :destroy ]

  def create
    @comment = @task.comments.build(comment_params)
    @comment.user = current_user

    if @comment.save
      redirect_to task_path(@task, anchor: "comment-#{@comment.id}"),
                  notice: t("flash.comment_posted")
    else
      redirect_to task_path(@task),
                  alert: @comment.errors.full_messages.to_sentence
    end
  end

  def destroy
    unless @comment.user_id == current_user.id
      return redirect_to task_path(@task), alert: t("flash.comment_own_only")
    end

    @comment.destroy
    redirect_to task_path(@task), notice: t("flash.comment_deleted")
  end

  private

  def set_task
    @task = Task.find(params[:task_id])
  end

  def authorize!
    require_project_member!(@task.project)
  end

  def set_comment
    @comment = @task.comments.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:body)
  end
end
