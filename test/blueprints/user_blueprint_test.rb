require "test_helper"

class UserBlueprintTest < ActiveSupport::TestCase
  def alice = users(:alice)

  test "default view includes id, email, display_name, timestamps" do
    result = UserBlueprint.render_as_hash(alice)

    assert_equal alice.id,           result[:id]
    assert_equal alice.email,        result[:email]
    assert_equal alice.display_name, result[:display_name]
    assert result[:created_at].present?
    assert result[:updated_at].present?
    assert_not result.key?(:encrypted_password), "password hash must never be exposed"
  end

  test "timestamps are ISO-8601 strings" do
    result = UserBlueprint.render_as_hash(alice)
    assert_match(/\d{4}-\d{2}-\d{2}T/, result[:created_at])
  end

  test "with_stats view adds counts" do
    result = UserBlueprint.render_as_hash(alice, view: :with_stats)
    assert result.key?(:projects_count)
    assert result.key?(:assigned_tasks_count)
  end

  test "render returns valid JSON string" do
    json = UserBlueprint.render(alice)
    parsed = JSON.parse(json)
    assert_equal alice.email, parsed["email"]
  end

  test "render_as_hash works for a collection" do
    results = UserBlueprint.render_as_hash([ alice, users(:bob) ])
    assert_equal 2, results.size
    assert results.all? { |r| r.key?(:email) }
  end
end
