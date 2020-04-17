get '/api/restaurants' do
    records = Restaurant.all()
    {
      status: 0,
      data: {
        restaurants: records.as_json(only: [:id, :name])
      }
    }.to_json
end

get '/api/restaurants/:id' do
  begin
    record = Restaurant.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    return 404, {
      status: 1,
      error: ErrorText::NOT_FOUND
    }.to_json
  end
  {
    status: 0,
    data: {
      restaurant: record.to_json()
    }
  }.to_json
end

post '/api/restaurants' do
  request.body.rewind
  json_body = JSON.parse(request.body.read)
  json_body.slice!(*Restaurant::WHITE_FIELDS)
  begin
    record = Restaurant.create(json_body)
  rescue ActiveRecord::RecordNotUnique
    return 409, {
      status: 1,
      error: ErrorText::NOT_UNIQUE
    }.to_json
  end
  return 201, {
    status: 0,
    data: {
      restaurant: record.to_json()
    }
  }.to_json
end

put '/api/restaurants/:id' do
  request.body.rewind
  json_body = JSON.parse(request.body.read)
  json_body.slice!(*Restaurant::WHITE_FIELDS)
  begin
    record = Restaurant.find(params[:id])
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
      restaurant: record.to_json()
    }
  }.to_json
end

delete '/api/restaurants/:id' do
  begin
    record = Restaurant.find(params[:id])
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
