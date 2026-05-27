require "test_helper"

class ProjectBlueprintTest < ActiveSupport::TestCase
  def alpha = projects(:alpha)
  def alice = users(:alice)

  test "default view includes core fields" do
    result = ProjectBlueprint.render_as_hash(alpha)

    assert_equal alpha.id,           result[:id]
    assert_equal alpha.name,         result[:name]
    assert_equal alpha.description,  result[:description]
    assert_equal alpha.status,       result[:status]
    assert_equal alpha.status_label, result[:status_label]
    assert result.key?(:member_count)
    assert result.key?(:tasks_count)
    assert result[:created_at].present?
  end

  test "default view does not embed members or tasks" do
    result = ProjectBlueprint.render_as_hash(alpha)
    assert_not result.key?(:members)
    assert_not result.key?(:tasks)
  end

  test "with_members view embeds member list" do
    result = ProjectBlueprint.render_as_hash(alpha, view: :with_members)
    assert result.key?(:members)
    emails = result[:members].map { |m| m[:email] }
    assert_includes emails, alice.email
  end

  test "with_tasks view embeds task summaries" do
    result = ProjectBlueprint.render_as_hash(alpha, view: :with_tasks)
    assert result.key?(:tasks)
    assert result[:tasks].all? { |t| t.key?(:title) && t.key?(:status_label) }
  end

  test "full view embeds both members and tasks" do
    result = ProjectBlueprint.render_as_hash(alpha, view: :full)
    assert result.key?(:members)
    assert result.key?(:tasks)
  end

  test "render returns valid JSON" do
    json    = ProjectBlueprint.render(alpha)
    parsed  = JSON.parse(json)
    assert_equal alpha.name, parsed["name"]
  end
end
