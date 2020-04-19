# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'table controller' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  before(:each) do
    @restaurant = Restaurant.create(
      { name: 'R', work_hour_start: 8, work_hour_stop: 22 }
    )
    @data = { restaurant_id: @restaurant.id, description: 'D' }
  end

  context 'get' do
    it 'empty list' do
      get '/api/tables'
      expect(last_response).to be_ok
      expect(last_response.body).to eq(
        {
          status: 0,
          data: {
            tables: []
          }
        }.to_json
      )
    end

    it 'list' do
      2.times do |i|
        Table.create({ description: i.to_s, restaurant_id: @restaurant.id })
      end
      get '/api/tables'
      expect(last_response).to be_ok
      expect(last_response.body).to eq(
        {
          status: 0,
          data: {
            tables: [
              { id: 1, description: '0' },
              { id: 2, description: '1' }
            ]
          }
        }.to_json
      )
    end

    it 'by id' do
      r = Table.create(@data)
      get "/api/tables/#{r.id}"
      expect(last_response).to be_ok
      expect(last_response.body).to eq(
        {
          status: 0,
          data: {
            table: { id: 1, description: 'D' }
          }
        }.to_json
      )
    end

    it 'by wrong id' do
      get '/api/tables/10000'
      expect(last_response.status).to eq(404)
      expect(JSON.parse(last_response.body)['error']).to eq(
        ErrorText::NOT_FOUND
      )
    end
  end

  context 'post' do
    it 'create one' do
      data = { description: 'D', restaurant_id: @restaurant.id }
      post '/api/tables', data, as: :json
      expect(last_response.status).to eq(201)
      expect(last_response.body).to eq(
        {
          status: 0,
          data: {
            table: { id: 1, description: 'D' }
          }
        }.to_json
      )
    end

    it 'invalid' do
      data = { description: 'R' }
      post '/api/tables', data, as: :json
      expect(last_response.status).to eq(409)
      expect(JSON.parse(last_response.body)['error']).to eq(
        ErrorText::INVALID
      )
    end
  end

  context 'put' do
    it 'update with json fields check' do
      r = Table.create(@data)
      put "/api/tables/#{r.id}", { description: 'R_new', id: 99_999 }, as: :json
      expect(last_response.status).to eq(201)
      expect(JSON.parse(last_response.body)).to eq(
        {
          status: 0,
          data: { table: { id: 1, description: 'R_new' } }
        }.with_indifferent_access
      )
      r.reload
      expect(r.description).to eq('R_new')
    end

    it 'wrong id' do
      put '/api/tables/10000', { description: 'R_new' }, as: :json
      expect(last_response.status).to eq(404)
      expect(JSON.parse(last_response.body)['error']).to eq(
        ErrorText::NOT_FOUND
      )
    end
  end

  context 'delete' do
    it 'by id' do
      r = Table.create(@data)
      delete "/api/tables/#{r.id}"
      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq(
        { status: 0 }.to_json
      )
      r = Table.last
      expect(r).to eq(nil)
    end

    it 'wrong id' do
      delete '/api/tables/10000'
      expect(last_response.status).to eq(404)
      expect(JSON.parse(last_response.body)['error']).to eq(
        ErrorText::NOT_FOUND
      )
    end
  end
end
