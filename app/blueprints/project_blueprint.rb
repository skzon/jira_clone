class ProjectBlueprint < BaseBlueprint
  identifier :id

  # :default — core project fields
  fields :name, :description, :status
  field(:status_label)    { |project| project.status_label }
  field(:member_count)    { |project| project.cached_member_count }
  field(:tasks_count)     { |project| project.tasks.size }

  # :with_members — includes the full member list (e.g. project detail page)
  view :with_members do
    include_view :default
    association :members, blueprint: UserBlueprint
  end

  # :with_tasks — includes summarised task list
  view :with_tasks do
    include_view :default
    association :tasks, blueprint: TaskBlueprint, view: :summary
  end

  # :full — everything: members + tasks
  view :full do
    include_view :with_members
    association :tasks, blueprint: TaskBlueprint, view: :summary
  end
end
