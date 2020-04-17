require 'spec_helper'

RSpec.describe 'user controller' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  context 'get' do
    it 'empty list' do
      get '/api/users'
      expect(last_response).to be_ok
      expect(last_response.body).to eq(
        {
          status: 0,
          data: {
            users: []
          }
        }.to_json
      )
    end

    it 'list' do
      r = User.create({name: 'R'})
      r = User.create({name: 'R2'})
      get '/api/users'
      expect(last_response).to be_ok
      expect(last_response.body).to eq(
        {
          status: 0,
          data: {
            users: [
              {id: 1, name: 'R'},
              {id: 2, name: 'R2'}
            ]
          }
        }.to_json
      )
    end

    it 'by id' do
      r = User.create({name: 'R'})
      get "/api/users/#{r.id}"
      expect(last_response).to be_ok
      expect(last_response.body).to eq(
        {
          status: 0, 
          data: {
            user: {id: 1, name: 'R'}
          }
        }.to_json
      )
    end

    it 'by wrong id' do
      get '/api/users/10000'
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
      post '/api/users', data, as: :json
      expect(last_response.status).to eq(201)
      last_user = User.last()
      expect(last_response.body).to eq(
        {
          status: 0,
          data: {
            user: {id: 1, name: 'R'}
          }
        }.to_json
      )
    end
  end

  context 'put' do
    it 'update with json fields check' do
      r = User.create({name: 'R'})
      put "/api/users/#{r.id}", {name: 'R_new', id: 99999}.to_json, as: :json
      expect(last_response.status).to eq(201)
      expect(last_response.body).to eq(
        {
          status: 0,
          data: {user: {id: 1, name: 'R_new'}}
        }.to_json
      )
      r.reload
      expect(r.name).to eq('R_new')
    end

    it 'wrong id' do
      put '/api/users/10000', {name: 'R_new'}.to_json, as: :json
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
      r = User.create({name: 'R'})
      delete "/api/users/#{r.id}"
      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq(
        {status: 0}.to_json
      )
      r = User.last()
      expect(r).to eq(nil)
    end

    it 'wrong id' do
      delete '/api/users/10000'
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
