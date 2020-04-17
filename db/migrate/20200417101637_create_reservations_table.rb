class CreateReservationsTable < ActiveRecord::Migration[6.0]
  def change
    create_table :reservations do |t|
      t.integer :user_id
      t.integer :table_id
      t.datetime :start_at
      t.datetime :stop_at
      t.datetime :created_at
      t.datetime :update_at
    end
    add_foreign_key :reservations, :users, on_delete: :cascade
    add_foreign_key :reservations, :tables, on_delete: :cascade
  end
end
