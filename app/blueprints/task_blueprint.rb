class TaskBlueprint < BaseBlueprint
  identifier :id

  # Root-level fields — included in ALL views (the minimal common contract)
  fields :title, :status
  field(:status_label) { |task| task.status_label }

  # :default — full task detail; adds description, project context, associations
  view :default do
    fields :description
    field(:project_id)   { |task| task.project_id }
    field(:project_name) { |task| task.project.name }
    association :assignee, blueprint: UserBlueprint, view: :default
    association :reporter, blueprint: UserBlueprint, view: :default
  end

  # :summary — lightweight for list views; only root fields + assignee name
  view :summary do
    field(:assignee_name) { |task| task.assignee&.display_name }
    field(:updated_at)    { |task| task.updated_at&.iso8601 }
  end

  # :with_comments — full detail + comment thread
  view :with_comments do
    include_view :default
    association :comments, blueprint: CommentBlueprint
  end
end
