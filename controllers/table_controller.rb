# frozen_string_literal: true

class TableController < Base
  get '/api/tables' do
    records = Table.all

    tables = []
    records.each { |r| tables << r.to_json }

    status 200
    {
      status: 0,
      data: {
        tables: tables
      }
    }.to_json
  end

  get '/api/tables/:id' do
    record = Table.find(params[:id])

    status 200
    {
      status: 0,
      data: {
        table: record.to_json
      }
    }.to_json
  end

  post '/api/tables' do
    record = Table.create!(table_params)

    status 201
    {
      status: 0,
      data: {
        table: record.to_json
      }
    }.to_json
  end

  put '/api/tables/:id' do
    record = Table.find(params[:id])

    record.description = description

    record.save!

    status 201
    {
      status: 0,
      data: {
        table: record.to_json
      }
    }.to_json
  end

  delete '/api/tables/:id' do
    record = Table.find(params[:id])

    record.destroy

    status 200
    {
      status: 0
    }.to_json
  end

  private

  def table_params
    params.slice(*Table::WHITE_FIELDS)
  end

  def description
    r = table_params['description']
    raise ActiveRecord::RecordInvalid if r.nil?

    r
  end
end

use TableController
