# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'user controller' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  before(:all) do
    @data = { name: 'R' }
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
      2.times do |i|
        User.create({ name: i.to_s })
      end
      get '/api/users'
      expect(last_response).to be_ok
      expect(last_response.body).to eq(
        {
          status: 0,
          data: {
            users: [
              { id: 1, name: '0' },
              { id: 2, name: '1' }
            ]
          }
        }.to_json
      )
    end

    it 'by id' do
      r = User.create(@data)
      get "/api/users/#{r.id}"
      expect(last_response).to be_ok
      expect(last_response.body).to eq(
        {
          status: 0,
          data: {
            user: { id: 1, name: 'R' }
          }
        }.to_json
      )
    end

    it 'by wrong id' do
      get '/api/users/10000'
      expect(last_response.status).to eq(404)
      expect(JSON.parse(last_response.body)['error']).to eq(
        ErrorText::NOT_FOUND
      )
    end
  end

  context 'post' do
    it 'create one' do
      post '/api/users', @data, as: :json
      expect(last_response.status).to eq(201)
      expect(last_response.body).to eq(
        {
          status: 0,
          data: {
            user: { id: 1, name: 'R' }
          }
        }.to_json
      )
    end
  end

  context 'put' do
    it 'update with json fields check' do
      r = User.create(@data)
      put "/api/users/#{r.id}", { name: 'R_new', id: 99_999 }, as: :json
      expect(last_response.status).to eq(201)
      expect(last_response.body).to eq(
        {
          status: 0,
          data: { user: { id: 1, name: 'R_new' } }
        }.to_json
      )
      r.reload
      expect(r.name).to eq('R_new')
    end

    it 'wrong id' do
      put '/api/users/10000', { name: 'R_new' }, as: :json
      expect(last_response.status).to eq(404)
      expect(JSON.parse(last_response.body)['error']).to eq(
        ErrorText::NOT_FOUND
      )
    end
  end

  context 'delete' do
    it 'by id' do
      r = User.create(@data)
      delete "/api/users/#{r.id}"
      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq(
        { status: 0 }.to_json
      )
      r = User.last
      expect(r).to eq(nil)
    end

    it 'wrong id' do
      delete '/api/users/10000'
      expect(last_response.status).to eq(404)
      expect(JSON.parse(last_response.body)['error']).to eq(
        ErrorText::NOT_FOUND
      )
    end
  end
end
