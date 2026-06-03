class CreateProjectMembers < ActiveRecord::Migration[8.1]
  def up
    create_table :project_members do |t|
      t.references :user,    null: false, foreign_key: true
      t.references :project, null: false, foreign_key: true
      t.timestamps
    end

    add_index :project_members, [ :user_id, :project_id ], unique: true

    # Projects are now shared across many users; the original "owner" column
    # becomes a "created_by" pointer that may be NULL once the creator leaves.
    change_column_null :projects, :user_id, true

    # Backfill: every existing project's creator becomes the first member.
    execute <<~SQL
      INSERT INTO project_members (user_id, project_id, created_at, updated_at)
      SELECT user_id, id, NOW(), NOW()
      FROM projects
      WHERE user_id IS NOT NULL
    SQL
  end

  def down
    drop_table :project_members
    change_column_null :projects, :user_id, false
  end
end
