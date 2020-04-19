# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'reservation model' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  before(:all) do
    @start_at = Time.utc(2020, 4, 1, 10, 0, 0)
    @stop_at = Time.utc(2020, 4, 1, 11, 0, 0)
  end

  before(:each) do
    @restaurant = Restaurant.create({
                                      name: 'R',
                                      work_hour_start: 8,
                                      work_hour_stop: 22
                                    })
    @table = Table.create({ description: 'R', restaurant_id: @restaurant.id })
    @user = User.create({ name: 'U' })
    @data = {
      user_id: @user.id,
      table_id: @table.id,
      start_at: @start_at,
      stop_at: @stop_at
    }
  end

  context 'validation' do
    it 'ok' do
      r = Reservation.new(@data)
      expect(r.valid?).to be true
    end

    it 'user presence' do
      r = Reservation.new(@data.except(:user_id))
      r.valid?
      expect(r.errors[:user]).to include("can't be blank")
    end

    it 'table presence' do
      r = Reservation.new(@data.except(:table_id))
      r.valid?
      expect(r.errors[:table]).to include("can't be blank")
    end
  end

  context 'delete' do
    it 'cascade delete after table' do
      2.times do |i|
        Reservation.create({
                             user_id: @user.id,
                             table_id: @table.id,
                             start_at: @start_at + i * 60 * 60,
                             stop_at: @stop_at + i * 60 * 60
                           })
      end
      expect(Reservation.count).to eq(2)
      @table.destroy
      expect(Reservation.count).to eq(0)
    end

    it 'cascade delete after user' do
      2.times do |i|
        Reservation.create({
                             user_id: @user.id,
                             table_id: @table.id,
                             start_at: @start_at + i * 60 * 60,
                             stop_at: @stop_at + i * 60 * 60
                           })
      end
      expect(Reservation.count).to eq(2)
      @user.destroy
      expect(Reservation.count).to eq(0)
    end
  end
end
