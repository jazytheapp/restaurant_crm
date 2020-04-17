require 'spec_helper'

RSpec.describe 'table controller' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  before(:each) do
    @restaurant = Restaurant.create({name: "R"})
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
      r = Table.create({description: 'R', restaurant_id: @restaurant.id})
      r = Table.create({description: 'R2', restaurant_id: @restaurant.id})
      get '/api/tables'
      expect(last_response).to be_ok
      expect(last_response.body).to eq(
        {
          status: 0,
          data: {
            tables: [
              {id: 1, description: 'R'},
              {id: 2, description: 'R2'}
            ]
          }
        }.to_json
      )
    end

    it 'by id' do
      r = Table.create({description: 'R', restaurant_id: @restaurant.id})
      get "/api/tables/#{r.id}"
      expect(last_response).to be_ok
      expect(last_response.body).to eq(
        {
          status: 0, 
          data: {
            table: {id: 1, description: 'R'}
          }
        }.to_json
      )
    end

    it 'by wrong id' do
      get '/api/tables/10000'
      expect(last_response.status).to eq(404)
      expect(last_response.body).to eq(
        {
          status: 1,
          error: ErrorText::NOT_FOUND
        }.to_json
      )
    end
  end

  context 'post' do
    it 'create one' do
      data = {description: 'R', restaurant_id: @restaurant.id}.to_json
      post '/api/tables', data, as: :json
      expect(last_response.status).to eq(201)
      last_table = Table.last()
      expect(last_response.body).to eq(
        {
          status: 0,
          data: {
            table: {id: 1, description: 'R'}
          }
        }.to_json
      )
    end
    it 'invalid' do
      data = {description: 'R'}.to_json
      post '/api/tables', data, as: :json
      expect(last_response.status).to eq(409)
      expect(last_response.body).to eq(
        {
          status: 1,
          error: ErrorText::INVALID
        }.to_json
      )
    end
  end

  context 'put' do
    it 'update with json fields check' do
      r = Table.create({description: 'R', restaurant_id: @restaurant.id})
      put "/api/tables/#{r.id}", {description: 'R_new', id: 99999}.to_json, as: :json
      expect(last_response.status).to eq(201)
      expect(last_response.body).to eq(
        {
          status: 0,
          data: {table: {id: 1, description: 'R_new'}}
        }.to_json
      )
      r.reload
      expect(r.description).to eq('R_new')
    end

    it 'wrong id' do
      put '/api/tables/10000', {description: 'R_new'}.to_json, as: :json
      expect(last_response.status).to eq(404)
      expect(last_response.body).to eq(
        {
          status: 1,
          error: ErrorText::NOT_FOUND
        }.to_json
      )
    end
  end

  context 'delete' do
    it 'by id' do
      r = Table.create({description: 'R', restaurant_id: @restaurant.id})
      delete "/api/tables/#{r.id}"
      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq(
        {status: 0}.to_json
      )
      r = Table.last()
      expect(r).to eq(nil)
    end

    it 'wrong id' do
      delete '/api/tables/10000'
      expect(last_response.status).to eq(404)
      expect(last_response.body).to eq(
        {
          status: 1,
          error: ErrorText::NOT_FOUND
        }.to_json
      )
    end
  end
end
