require "test_helper"

class ProjectMemberBlueprintTest < ActiveSupport::TestCase
  def alice_alpha = project_members(:alice_alpha)
  def alice       = users(:alice)
  def alpha       = projects(:alpha)

  test "default view embeds user and project" do
    result = ProjectMemberBlueprint.render_as_hash(alice_alpha)

    assert_equal alice_alpha.id,  result[:id]
    assert_equal alice.email,     result.dig(:user, :email)
    assert_equal alpha.name,      result.dig(:project, :name)
    assert result[:created_at].present?
  end

  test "render returns valid JSON" do
    json   = ProjectMemberBlueprint.render(alice_alpha)
    parsed = JSON.parse(json)
    assert_equal alice.email, parsed.dig("user", "email")
  end
end
