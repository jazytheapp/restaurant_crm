# frozen_string_literal: true

class RestaurantController < Base
  get '/api/restaurants' do
    records = Restaurant.all

    status 200
    {
      status: 0,
      data: {
        restaurants: records.map(&:to_json)
      }
    }.to_json
  end

  get '/api/restaurants/:id' do
    record = Restaurant.find(params[:id])

    status 200
    {
      status: 0,
      data: {
        restaurant: record.to_json
      }
    }.to_json
  end

  post '/api/restaurants' do
    record = Restaurant.create!(restaurant_params)

    status 201
    {
      status: 0,
      data: {
        restaurant: record.to_json
      }
    }.to_json
  end

  put '/api/restaurants/:id' do
    record = Restaurant.find(params[:id])

    record.update!(restaurant_params)

    status 201
    {
      status: 0,
      data: {
        restaurant: record.to_json
      }
    }.to_json
  end

  delete '/api/restaurants/:id' do
    record = Restaurant.find(params[:id])

    record.destroy

    status 200
    {
      status: 0
    }.to_json
  end

  private

  def restaurant_params
    params.slice(*Restaurant::WHITE_FIELDS)
  end
end

use RestaurantController
