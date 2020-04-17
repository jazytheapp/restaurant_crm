require 'spec_helper'

RSpec.describe 'table model' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  before(:each) do
    @restaurant = Restaurant.create({name: "R"})
  end

  context 'delete' do
    it 'cascade delete after restaurant' do
      2.times {
        |i|
        r = Table.create({description: i.to_s, restaurant_id: @restaurant.id})
      }
      expect(Table.count).to eq(2)
      @restaurant.destroy
      expect(Table.count).to eq(0)
    end
  end
end
