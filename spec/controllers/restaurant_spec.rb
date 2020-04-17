require 'spec_helper'

RSpec.describe 'restaurant controller' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  context 'get' do
    it 'empty list' do
      get '/api/restaurants'
      expect(last_response).to be_ok
      expect(last_response.body).to eq(
        {
          status: 0,
          data: {
            restaurants: []
          }
        }.to_json
      )
    end

    it 'list' do
      r = Restaurant.create({name: 'R'})
      r = Restaurant.create({name: 'R2'})
      get '/api/restaurants'
      expect(last_response).to be_ok
      expect(last_response.body).to eq(
        {
          status:0,
          data: {
            restaurants: [
              {id: 1, name: 'R'},
              {id: 2, name: 'R2'}
            ]
          }
        }.to_json
      )
    end

    it 'by id' do
      r = Restaurant.create({name: 'R'})
      get "/api/restaurants/#{r.id}"
      expect(last_response).to be_ok
      expect(last_response.body).to eq(
        {
          status:0, 
          data: {
            restaurant: {id: 1, name: 'R'}
          }
        }.to_json
      )
    end

    it 'by wrong id' do
      get '/api/restaurants/10000'
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
      data = {name: 'R', work_hour_start: 8, work_hour_stop: 22}.to_json
      post '/api/restaurants', data, as: :json
      expect(last_response.status).to eq(201)
      last_restaurant = Restaurant.last()
      expect(last_response.body).to eq(
        {
          status:0,
          data: {
            restaurant: {id: 1, name: 'R'}
          }
        }.to_json
      )
    end

    it 'create dublicate' do
      data = {name: 'R'}.to_json
      post '/api/restaurants', data, as: :json
      expect(last_response.status).to eq(201)

      post '/api/restaurants', data, as: :json
      expect(last_response.status).to eq(409)
      expect(last_response.body).to eq(
        {
          status: 1,
          error: ErrorText::NOT_UNIQUE
        }.to_json
      )
    end
  end

  context 'put' do
    it 'update with json fields check' do
      r = Restaurant.create({name: 'R'})
      put "/api/restaurants/#{r.id}", {name: 'R_new', id: 99999}.to_json, as: :json
      expect(last_response.status).to eq(201)
      expect(last_response.body).to eq(
        {
          status: 0,
          data: {restaurant: {id: 1, name: 'R_new'}}
        }.to_json
      )
      r.reload
      expect(r.name).to eq('R_new')
    end

    it 'wrong id' do
      put '/api/restaurants/10000', {name: 'R_new'}.to_json, as: :json
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
      r = Restaurant.create({name: 'R'})
      delete "/api/restaurants/#{r.id}"
      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq(
        {status: 0}.to_json
      )
      r = Restaurant.last()
      expect(r).to eq(nil)
    end

    it 'wrong id' do
      delete '/api/restaurants/10000'
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
