class ProjectMemberBlueprint < BaseBlueprint
  identifier :id

  # :default — membership record with embedded user + project summaries
  association :user,    blueprint: UserBlueprint,    view: :default
  association :project, blueprint: ProjectBlueprint, view: :default
end
