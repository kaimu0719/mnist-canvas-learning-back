class CreatePredictionLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :prediction_logs do |t|
      t.references :drawing, null: false, foreign_key: true
      t.string :job_id, null: false
      t.string :status, null: false
      t.integer :answer, null: true
      t.timestamps
    end
  end
end
