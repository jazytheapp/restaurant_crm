get '/api/users' do
    records = User.all()
    {
      status: 0,
      data: {
        users: records.as_json(only: [:id, :name])
      }
    }.to_json
end

get '/api/users/:id' do
  begin
    record = User.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    return 404, {
      status: 1,
      error: ErrorText::NOT_FOUND
    }.to_json
  end
  {
    status: 0,
    data: {
      user: record.to_json()
    }
  }.to_json
end

post '/api/users' do
  request.body.rewind
  json_body = JSON.parse(request.body.read)
  json_body.slice!(*User::WHITE_FIELDS)
  record = User.create(json_body)
  return 201, {
    status: 0,
    data: {
      user: record.to_json()
    }
  }.to_json
end

put '/api/users/:id' do
  request.body.rewind
  json_body = JSON.parse(request.body.read)
  json_body.slice!(*User::WHITE_FIELDS)
  begin
    record = User.find(params[:id])
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
      user: record.to_json()
    }
  }.to_json
end

delete '/api/users/:id' do
  begin
    record = User.find(params[:id])
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
