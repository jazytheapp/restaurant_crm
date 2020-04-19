# frozen_string_literal: true

# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20_200_417_101_637) do
  create_table 'reservations', force: :cascade do |t|
    t.integer 'user_id'
    t.integer 'table_id'
    t.datetime 'start_at'
    t.datetime 'stop_at'
    t.datetime 'created_at'
    t.datetime 'update_at'
  end

  create_table 'restaurants', force: :cascade do |t|
    t.string 'name'
    t.integer 'work_hour_start'
    t.integer 'work_hour_stop'
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.index ['name'], name: 'index_restaurants_on_name', unique: true
  end

  create_table 'tables', force: :cascade do |t|
    t.integer 'restaurant_id'
    t.string 'description'
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.index ['restaurant_id'], name: 'index_tables_on_restaurant_id'
  end

  create_table 'users', force: :cascade do |t|
    t.string 'name'
    t.datetime 'created_at'
    t.datetime 'updated_at'
  end

  add_foreign_key 'reservations', 'tables', on_delete: :cascade
  add_foreign_key 'reservations', 'users', on_delete: :cascade
end
