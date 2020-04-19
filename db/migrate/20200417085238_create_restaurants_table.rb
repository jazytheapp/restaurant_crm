# frozen_string_literal: true

class CreateRestaurantsTable < ActiveRecord::Migration[6.0]
  def change
    create_table :restaurants do |t|
      t.string :name
      t.integer :work_hour_start
      t.integer :work_hour_stop
      t.datetime :created_at
      t.datetime :updated_at
    end
    add_index :restaurants, :name, unique: true
  end
end
