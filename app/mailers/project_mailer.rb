class ProjectMailer < ApplicationMailer
  def added(project, recipient, actor)
    @project = project
    @recipient = recipient
    @actor = actor
    @project_url = project_url(project)

    return if @recipient.blank?

    mail to: @recipient.email,
         subject: "You've been added to #{@project.name}"
  end
end
