module ApplicationHelper
  STATUS_BADGE_CLASSES = {
    "active" => "is-active",
    "in_progress" => "is-progress",
    "to_do" => "is-todo",
    "todo" => "is-todo",
    "on_hold" => "is-hold",
    "blocked" => "is-blocked",
    "completed" => "is-done",
    "done" => "is-done"
  }.freeze

  def status_badge(status)
    label = (status.presence || "active").to_s
    key = label.downcase.tr(" -", "__")
    css = STATUS_BADGE_CLASSES[key] || "is-active"

    content_tag(:span, label.humanize, class: "jira-badge #{css}")
  end
end
