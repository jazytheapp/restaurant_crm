require 'spec_helper'

RSpec.describe 'reservation model' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  before(:all) do
    @start_at = Time.now.utc
    @stop_at = Time.now.utc + 30*60
  end

  before(:each) do
    @restaurant = Restaurant.create({name: "R"})
    @table = Table.create({description: "R", restaurant_id: @restaurant.id})
    @user = User.create({name: "U"})
  end

  context 'delete' do
    it 'cascade delete after table' do
      2.times {
        Reservation.create({
          user_id: @user.id,
          table_id: @table.id,
          start_at: @start_at,
          stop_at: @stop_at,
        })
      }
      expect(Reservation.count).to eq(2)
      @table.destroy
      expect(Reservation.count).to eq(0)
    end

    it 'cascade delete after user' do
      2.times {
        Reservation.create({
          user_id: @user.id,
          table_id: @table.id,
          start_at: @start_at,
          stop_at: @stop_at,
        })
      }
      expect(Reservation.count).to eq(2)
      @user.destroy
      expect(Reservation.count).to eq(0)
    end
  end
end
