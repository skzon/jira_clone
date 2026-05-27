require "test_helper"

class TaskBlueprintTest < ActiveSupport::TestCase
  def open_task = tasks(:open_task)
  def alice     = users(:alice)
  def bob       = users(:bob)

  test "default view includes core fields and associations" do
    result = TaskBlueprint.render_as_hash(open_task)

    assert_equal open_task.id,           result[:id]
    assert_equal open_task.title,        result[:title]
    assert_equal open_task.status,       result[:status]
    assert_equal open_task.status_label, result[:status_label]
    assert_equal open_task.project_id,   result[:project_id]
    assert_equal open_task.project.name, result[:project_name]
    assert result[:created_at].present?
  end

  test "default view embeds assignee and reporter as user objects" do
    result = TaskBlueprint.render_as_hash(open_task)

    assert_equal bob.email,   result.dig(:assignee, :email)
    assert_equal alice.email, result.dig(:reporter, :email)
  end

  test "assignee is nil for unassigned tasks" do
    result = TaskBlueprint.render_as_hash(tasks(:in_progress_task))
    assert_nil result[:assignee]
  end

  test "summary view includes lightweight fields" do
    result = TaskBlueprint.render_as_hash(open_task, view: :summary)

    assert result.key?(:title)
    assert result.key?(:status)
    assert result.key?(:status_label)
    assert result.key?(:assignee_name)
    assert result.key?(:updated_at)
  end

  test "summary assignee_name returns display name string not object" do
    result = TaskBlueprint.render_as_hash(open_task, view: :summary)
    assert_equal bob.display_name, result[:assignee_name]
  end

  test "summary assignee_name is nil for unassigned tasks" do
    result = TaskBlueprint.render_as_hash(tasks(:in_progress_task), view: :summary)
    assert_nil result[:assignee_name]
  end

  test "with_comments view embeds comment thread" do
    result = TaskBlueprint.render_as_hash(open_task, view: :with_comments)
    assert result.key?(:comments)
    assert result[:comments].all? { |c| c.key?(:body) }
  end

  test "no sensitive fields are ever exposed" do
    [ :default, :summary, :with_comments ].each do |view|
      result = TaskBlueprint.render_as_hash(open_task, view: view)
      assert_not result.key?(:encrypted_password), "#{view} must not expose password"
    end
  end

  test "render returns valid JSON" do
    json   = TaskBlueprint.render(open_task)
    parsed = JSON.parse(json)
    assert_equal open_task.title, parsed["title"]
  end
end
