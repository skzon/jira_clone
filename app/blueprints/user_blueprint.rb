class UserBlueprint < BaseBlueprint
  identifier :id

  # :default — safe public fields only (no password hash, no tokens)
  fields :email
  field(:display_name) { |user| user.display_name }

  # :with_stats — adds project + task counts, useful for profile/admin views
  view :with_stats do
    include_view :default
    field(:projects_count)  { |user| user.projects.size }
    field(:assigned_tasks_count) { |user| user.assigned_tasks.size }
  end
end
