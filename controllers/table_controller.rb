get '/api/tables' do
    records = Table.all()
    {
      status: 0,
      data: {
        tables: records.as_json(only: [:id, :description])
      }
    }.to_json
end

get '/api/tables/:id' do
  begin
    record = Table.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    return 404, {
      status: 1,
      error: ErrorText::NOT_FOUND
    }.to_json
  end
  {
    status: 0,
    data: {
      table: record.to_json()
    }
  }.to_json
end

post '/api/tables' do
  request.body.rewind
  json_body = JSON.parse(request.body.read)
  json_body.slice!(*Table::WHITE_FIELDS)
  record = Table.create(json_body)
  if !(record.valid?)
    return 409, {
      status: 1,
      error: ErrorText::INVALID
    }.to_json
  
  end
  return 201, {
    status: 0,
    data: {
      table: record.to_json()
    }
  }.to_json
end

put '/api/tables/:id' do
  request.body.rewind
  json_body = JSON.parse(request.body.read)
  json_body.slice!(*Table::WHITE_FIELDS)
  begin
    record = Table.find(params[:id])
    record.update(json_body)
  rescue ActiveRecord::RecordNotFound
    return 404, {
      status: 1,
      error: ErrorText::NOT_FOUND
    }.to_json
  end
  return 201, {
    status: 0,
    data: {
      table: record.to_json()
    }
  }.to_json
end

delete '/api/tables/:id' do
  begin
    record = Table.find(params[:id])
    record.destroy
  rescue ActiveRecord::RecordNotFound
    return 404, {
      status: 1,
      error: ErrorText::NOT_FOUND
    }.to_json
  end
  return 200, {
    status: 0
  }.to_json
end
