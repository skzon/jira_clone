class TaskMailer < ApplicationMailer
  def assigned(task, actor)
    @task = task
    @actor = actor
    @recipient = task.assignee
    @task_url = task_url(task)

    return if @recipient.blank?

    mail to: @recipient.email,
         subject: "[#{@task.project.name}] You've been assigned: #{@task.title}"
  end

  def updated(task, actor, changes)
    @task = task
    @actor = actor
    @changes = changes || {}
    @task_url = task_url(task)

    recipients = (task.participants - [ actor ].compact).map(&:email).uniq
    return if recipients.empty?

    mail to: recipients,
         subject: "[#{@task.project.name}] Task updated: #{@task.title}"
  end

  def commented(comment)
    @comment = comment
    @task = comment.task
    @author = comment.user
    @task_url = task_url(@task)

    recipients = (@task.participants - [ @author ]).map(&:email).uniq
    return if recipients.empty?

    mail to: recipients,
         subject: "[#{@task.project.name}] New comment on: #{@task.title}"
  end
end
