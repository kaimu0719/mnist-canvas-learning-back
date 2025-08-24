class CreateDrawings < ActiveRecord::Migration[8.0]
  def change
    create_table :drawings do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :label, null: false
      t.timestamps
    end

    add_index :drawings, [:user_id, :created_at]
    add_index :drawings, :label
  end
end
