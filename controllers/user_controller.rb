# frozen_string_literal: true

class UserController < Base
  get '/api/users' do
    records = User.all

    status 200
    {
      status: 0,
      data: {
        users: records.map(&:to_json)
      }
    }.to_json
  end

  get '/api/users/:id' do
    record = User.find(params[:id])

    status 200
    {
      status: 0,
      data: {
        user: record.to_json
      }
    }.to_json
  end

  post '/api/users' do
    record = User.create!(user_params)

    status 201
    {
      status: 0,
      data: {
        user: record.to_json
      }
    }.to_json
  end

  put '/api/users/:id' do
    record = User.find(params[:id])

    record.update!(user_params)

    status 201
    {
      status: 0,
      data: {
        user: record.to_json
      }
    }.to_json
  end

  delete '/api/users/:id' do
    record = User.find(params[:id])

    record.destroy

    status 200
    {
      status: 0
    }.to_json
  end

  private

  def user_params
    params.slice(*User::WHITE_FIELDS)
  end
end

use UserController
