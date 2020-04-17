class CreateTablesTable < ActiveRecord::Migration[6.0]
  def change
    create_table :tables do |t|
      t.belongs_to :restaurant
      t.string :description
      t.datetime :created_at
      t.datetime :updated_at
    end
  end
end
