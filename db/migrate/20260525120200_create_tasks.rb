class CreateTasks < ActiveRecord::Migration[8.1]
  def change
    create_table :tasks do |t|
      t.string  :title,       null: false
      t.text    :description
      t.string  :status,      null: false, default: "to_do"
      t.references :project,  null: false, foreign_key: true
      t.references :reporter, foreign_key: { to_table: :users }
      t.references :assignee, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :tasks, :status
  end
end
