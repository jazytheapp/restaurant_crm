# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'restaurant model' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  before(:all) do
    @data = { name: 'R', work_hour_start: 8, work_hour_stop: 22 }.freeze
  end

  context 'validation' do
    it 'ok' do
      r = Restaurant.new(@data)
      expect(r.valid?).to be true
    end

    it 'name presence' do
      r = Restaurant.new(@data.except(:name))
      r.valid?
      expect(r.errors[:name]).to include("can't be blank")
    end

    it 'work_hour_start presence' do
      r = Restaurant.new(@data.except(:work_hour_start))
      r.valid?
      expect(r.errors[:work_hour_start]).to include("can't be blank")
    end

    it 'work_hour_stop presence' do
      r = Restaurant.new(@data.except(:work_hour_stop))
      r.valid?
      expect(r.errors[:work_hour_stop]).to include("can't be blank")
    end

    it 'work_hours' do
      [-1, 25].each do |hour|
        r = Restaurant.new(work_hour_start: hour, work_hour_stop: hour)
        r.valid?
        expect(r.errors[:work_hour_start]).to include('wrong time')
        expect(r.errors[:work_hour_stop]).to include('wrong time')
      end
    end
  end
end
