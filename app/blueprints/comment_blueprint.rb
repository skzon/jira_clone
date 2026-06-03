class CommentBlueprint < BaseBlueprint
  identifier :id

  # :default — comment body + author summary
  fields :body
  field(:task_id)       { |comment| comment.task_id }
  association :user, blueprint: UserBlueprint, view: :default
end
