class ApplicationMailer < ActionMailer::Base
  default from: "Jira Clone <notifications@jira-clone.local>"
  layout "mailer"
end
