# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'table model' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  before(:each) do
    @restaurant = Restaurant.create({
                                      name: 'R',
                                      work_hour_start: 8,
                                      work_hour_stop: 22
                                    })
    @data = { restaurant_id: @restaurant.id, description: 'D' }
  end

  context 'validation' do
    it 'ok' do
      r = Table.new(@data)
      expect(r.valid?).to be true
    end

    it 'restaurant_id presence' do
      r = Table.new(@data.except(:restaurant_id))
      r.valid?
      expect(r.errors[:restaurant]).to include("can't be blank")
    end

    it 'description presence' do
      r = Table.new(@data.except(:description))
      r.valid?
      expect(r.errors[:description]).to include("can't be blank")
    end
  end

  context 'delete' do
    it 'cascade delete after restaurant' do
      2.times do |i|
        Table.create({ description: i.to_s, restaurant_id: @restaurant.id })
      end
      expect(Table.count).to eq(2)
      @restaurant.destroy
      expect(Table.count).to eq(0)
    end
  end
end
