# frozen_string_literal: true

class ReservationController < Base
  get '/api/reservations' do
    records = Reservation.all

    status 200
    {
      status: 0,
      data: {
        reservations: records.map(&:to_json)
      }
    }.to_json
  end

  get '/api/reservations/:id' do
    record = Reservation.find(params[:id])
    {
      status: 0,
      data: {
        reservation: record.to_json
      }
    }.to_json
  end

  post '/api/reservations' do
    record = Reservation.new(reservation_params)

    record.start_at = start_at
    record.stop_at = stop_at

    record.save!

    status 201
    {
      status: 0,
      data: {
        reservation: record.to_json
      }
    }.to_json
  end

  put '/api/reservations/:id' do
    record = Reservation.find(params[:id])

    record.start_at = start_at
    record.stop_at = stop_at

    record.save!

    status 201
    {
      status: 0,
      data: {
        reservation: record.to_json
      }
    }.to_json
  end

  delete '/api/reservations/:id' do
    record = Reservation.find(params[:id])

    record.destroy

    status 200
    {
      status: 0
    }.to_json
  end

  private

  def reservation_params
    params.slice(*Reservation::WHITE_FIELDS)
  end

  def start_at
    r = reservation_params['start_at']
    raise ActiveRecord::RecordInvalid if r.nil?

    Time.at(r.to_i)
  end

  def stop_at
    r = reservation_params['stop_at']
    raise ActiveRecord::RecordInvalid if r.nil?

    Time.at(r.to_i)
  end
end

use ReservationController
