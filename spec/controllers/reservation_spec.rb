# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'reservation controller' do
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

  context 'get' do
    it 'empty list' do
      get '/api/reservations'
      expect(last_response).to be_ok
      expect(last_response.body).to eq(
        {
          status: 0,
          data: {
            reservations: []
          }
        }.to_json
      )
    end

    it 'list' do
      2.times do |i|
        Reservation.create({
                             user_id: @user.id,
                             table_id: @table.id,
                             start_at: @start_at + i * 60 * 60,
                             stop_at: @stop_at + i * 60 * 60
                           })
      end
      get '/api/reservations'
      expect(last_response).to be_ok
      expect(JSON.parse(last_response.body)).to eq(
        {
          status: 0,
          data: {
            reservations: [
              {
                id: 1,
                user_id: @user.id,
                table_id: @table.id,
                start_at: @start_at.to_i,
                stop_at: @stop_at.to_i
              },
              {
                id: 2,
                user_id: @user.id,
                table_id: @table.id,
                start_at: (@start_at + 60 * 60).to_i,
                stop_at: (@stop_at + 60 * 60).to_i
              }
            ]
          }
        }.with_indifferent_access
      )
    end

    it 'by id' do
      r = Reservation.create(@data)
      get "/api/reservations/#{r.id}"
      expect(last_response).to be_ok
      expect(JSON.parse(last_response.body)).to eq(
        {
          status: 0,
          data: {
            reservation: {
              id: 1,
              user_id: @user.id,
              table_id: @table.id,
              start_at: @start_at.to_i,
              stop_at: @stop_at.to_i
            }
          }
        }.with_indifferent_access
      )
    end

    it 'by wrong id' do
      get '/api/reservations/10000'
      expect(last_response.status).to eq(404)
      expect(JSON.parse(last_response.body)['error']).to eq(
        ErrorText::NOT_FOUND
      )
    end
  end

  context 'post' do
    it 'create one' do
      data_to_send = {
        user_id: @user.id,
        table_id: @table.id,
        start_at: @start_at.to_i,
        stop_at: @stop_at.to_i
      }
      post '/api/reservations', data_to_send, as: :json
      expect(last_response.status).to eq(201)
      expect(JSON.parse(last_response.body)).to eq(
        {
          status: 0,
          data: {
            reservation: {
              id: 1,
              user_id: @user.id,
              table_id: @table.id,
              start_at: @start_at.to_i,
              stop_at: @stop_at.to_i
            }
          }
        }.with_indifferent_access
      )
    end

    it 'start_at > stop_at' do
      data = {
        user_id: @user.id,
        table_id: @table.id,
        stop_at: @start_at.to_i,
        start_at: @stop_at.to_i
      }.to_json
      post '/api/reservations', data, as: :json
      expect(last_response.status).to eq(409)
    end

    it '(stop_at - start_at) != 30 min' do
      data = {
        user_id: @user.id,
        table_id: @table.id,
        start_at: @start_at.to_i,
        stop_at: (@start_at + 10).to_i
      }.to_json
      post '/api/reservations', data, as: :json
      expect(last_response.status).to eq(409)
    end

    it 'miss fields' do
      data = {
        start_at: @start_at.to_i,
        stop_at: @stop_at.to_i
      }.to_json
      post '/api/reservations', data, as: :json
      expect(last_response.status).to eq(409)
      expect(JSON.parse(last_response.body)['error']).to eq(
        ErrorText::INVALID
      )
    end

    it 'invalid user_id' do
      data = {
        user_id: 1000,
        table_id: @table.id,
        start_at: @start_at.to_i,
        stop_at: @stop_at.to_i
      }.to_json
      post '/api/reservations', data, as: :json
      expect(last_response.status).to eq(409)
      expect(JSON.parse(last_response.body)['error']).to eq(
        ErrorText::INVALID
      )
    end

    it 'invalid table_id' do
      data = {
        user_id: @user.id,
        table_id: 1000,
        start_at: @start_at.to_i,
        stop_at: @stop_at.to_i
      }.to_json
      post '/api/reservations', data, as: :json
      expect(last_response.status).to eq(409)
      expect(JSON.parse(last_response.body)['error']).to eq(
        ErrorText::INVALID
      )
    end

    it 'restaurant closed morning' do
      data = {
        user_id: @user.id,
        table_id: @table.id,
        start_at: Time.utc(2020, 4, 1, 1, 0, 0).to_i,
        stop_at: @stop_at.to_i
      }.to_json
      post '/api/reservations', data, as: :json
      expect(last_response.status).to eq(409)
      expect(JSON.parse(last_response.body)['error']).to eq(
        ErrorText::INVALID
      )
    end

    it 'restaurant closed night' do
      data = {
        user_id: @user.id,
        table_id: @table.id,
        start_at: @start_at.to_i,
        stop_at: Time.utc(2020, 4, 1, 23, 0, 0).to_i
      }.to_json
      post '/api/reservations', data, as: :json
      expect(last_response.status).to eq(409)
      expect(JSON.parse(last_response.body)['error']).to eq(
        ErrorText::INVALID
      )
    end

    it 'dublicate by user same time' do
      Reservation.create({
                           user_id: @user.id,
                           table_id: @table.id,
                           start_at: @start_at,
                           stop_at: @stop_at
                         })
      data = {
        user_id: @user.id,
        table_id: @table.id,
        start_at: @start_at.to_i,
        stop_at: @stop_at.to_i
      }.to_json
      post '/api/reservations', data, as: :json
      expect(last_response.status).to eq(409)
      expect(JSON.parse(last_response.body)['error']).to eq(
        ErrorText::INVALID
      )
    end

    it 'dublicate by user shift time' do
      Reservation.create({
                           user_id: @user.id,
                           table_id: @table.id,
                           start_at: @start_at,
                           stop_at: @stop_at
                         })
      data = {
        user_id: @user.id,
        table_id: @table.id,
        start_at: (@start_at + 60).to_i,
        stop_at: (@stop_at + 60).to_i
      }.to_json
      post '/api/reservations', data, as: :json
      expect(last_response.status).to eq(409)
      expect(JSON.parse(last_response.body)['error']).to eq(
        ErrorText::INVALID
      )
    end

    it 'start_at == previous stop_at' do
      Reservation.create({
                           user_id: @user.id,
                           table_id: @table.id,
                           start_at: @start_at,
                           stop_at: @stop_at
                         })
      data = {
        user_id: @user.id,
        table_id: @table.id,
        start_at: @stop_at.to_i,
        stop_at: (@stop_at + 30 * 60).to_i
      }
      post '/api/reservations', data, as: :json
      expect(last_response.status).to eq(201)
    end

    it 'reserved on second table same restaurant' do
      Reservation.create({
                           user_id: @user.id,
                           table_id: @table.id,
                           start_at: @start_at,
                           stop_at: @stop_at
                         })
      table2 = Table.create({ description: 'R', restaurant_id: @restaurant.id })
      data = {
        user_id: @user.id,
        table_id: table2.id,
        start_at: @start_at.to_i,
        stop_at: @stop_at.to_i
      }
      post '/api/reservations', data, as: :json
      expect(last_response.status).to eq(201)
    end

    it 'reserved on other restaurant same time' do
      Reservation.create({
                           user_id: @user.id,
                           table_id: @table.id,
                           start_at: @start_at,
                           stop_at: @stop_at
                         })
      restaurant2 = Restaurant.create(
        { name: 'R2', work_hour_start: 8, work_hour_stop: 20 }
      )
      table2 = Table.create({ description: 'R', restaurant_id: restaurant2.id })
      data = {
        user_id: @user.id,
        table_id: table2.id,
        start_at: @start_at.to_i,
        stop_at: @stop_at.to_i
      }
      post '/api/reservations', data, as: :json
      expect(last_response.status).to eq(409)
      expect(JSON.parse(last_response.body)['error']).to eq(
        ErrorText::INVALID
      )
    end
  end

  context 'put' do
    it 'shift time ok' do
      r = Reservation.create({
                               user_id: @user.id,
                               table_id: @table.id,
                               start_at: @start_at,
                               stop_at: @stop_at
                             })
      start_at_s = (@start_at + 60).to_i
      stop_at_s = (@stop_at + 60).to_i
      data = {
        start_at: start_at_s,
        stop_at: stop_at_s
      }
      put "/api/reservations/#{r.id}", data, as: :json
      expect(last_response.status).to eq(201)
      expect(JSON.parse(last_response.body)).to eq(
        {
          status: 0,
          data: {
            reservation: {
              id: 1,
              user_id: @user.id,
              table_id: @table.id,
              start_at: start_at_s,
              stop_at: stop_at_s
            }
          }
        }.with_indifferent_access
      )
    end

    it 'shift time for restaurant closed' do
      r = Reservation.create({
                               user_id: @user.id,
                               table_id: @table.id,
                               start_at: @start_at,
                               stop_at: @stop_at
                             })

      start_at_s = Time.utc(2020, 4, 1, 22, 0, 0).to_i
      stop_at_s = Time.utc(2020, 4, 1, 23, 0, 0).to_i
      data = {
        start_at: start_at_s,
        stop_at: stop_at_s
      }
      put "/api/reservations/#{r.id}", data, as: :json
      expect(last_response.status).to eq(409)
      expect(JSON.parse(last_response.body)['error']).to eq(
        ErrorText::INVALID
      )
    end

    it 'other reservation at new time' do
      Reservation.create({
                           user_id: @user.id,
                           table_id: @table.id,
                           start_at: @start_at,
                           stop_at: @stop_at
                         })
      r = Reservation.create({
                               user_id: @user.id,
                               table_id: @table.id,
                               start_at: @start_at + 2 * 60 * 60,
                               stop_at: @stop_at + 2 * 60 * 60
                             })
      start_at_s = (@start_at + 60).to_i
      stop_at_s = (@stop_at + 60).to_i
      data = {
        start_at: start_at_s,
        stop_at: stop_at_s
      }
      put "/api/reservations/#{r.id}", data, as: :json
      expect(last_response.status).to eq(409)
      expect(JSON.parse(last_response.body)['error']).to eq(
        ErrorText::INVALID
      )
    end

    it 'wrong_id' do
      data = {
        start_at: @start_at.to_i,
        stop_at: @stop_at.to_i
      }
      put '/api/reservations/10000', data, as: :json
      expect(last_response.status).to eq(404)
      expect(JSON.parse(last_response.body)['error']).to eq(
        ErrorText::NOT_FOUND
      )
    end
  end

  context 'delete' do
    it 'by id' do
      r = Reservation.create(
        {
          user_id: @user.id,
          table_id: @table.id,
          start_at: @start_at,
          stop_at: @stop_at
        }
      )
      delete "/api/reservations/#{r.id}"
      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq(
        { status: 0 }.to_json
      )
      r = Reservation.last
      expect(r).to eq(nil)
    end

    it 'wrong id' do
      delete '/api/reservations/10000'
      expect(last_response.status).to eq(404)
      expect(JSON.parse(last_response.body)['error']).to eq(
        ErrorText::NOT_FOUND
      )
    end
  end
end
