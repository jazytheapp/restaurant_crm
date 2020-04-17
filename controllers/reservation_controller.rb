get '/api/reservations' do
    records = Reservation.all()
    reservations = []
    records.each {|r| reservations << r.to_json}
    {
      status: 0,
      data: {
        reservations: reservations
      }
    }.to_json
end

get '/api/reservations/:id' do
  begin
    record = Reservation.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    return 404, {
      status: 1,
      error: ErrorText::NOT_FOUND
    }.to_json
  end
  {
    status: 0,
    data: {
      reservation: record.to_json()
    }
  }.to_json
end

post '/api/reservations' do
  request.body.rewind
  json_body = JSON.parse(request.body.read)
  json_body.slice!(*Reservation::WHITE_FIELDS)

  Reservation::WHITE_FIELDS.each {
    |k|
    if !(json_body.key? k)
      return 409, {
        status: 1,
        error: ErrorText::INVALID
      }.to_json
    end
  }

  user_id = json_body['user_id']
  table_id = json_body['table_id']
  start_at = Time.at(json_body['start_at'])
  stop_at = Time.at(json_body['stop_at'])

  json_body['start_at'] = start_at
  json_body['stop_at'] = stop_at

  if start_at > stop_at || (stop_at - start_at) % (30*60) != 0
    return 409, {
      status: 1,
      error: ErrorText::INVALID_TIME
    }.to_json
  end

  user = User.exists?(user_id)
  if !user
    return 409, {
      status: 1,
      error: ErrorText::NO_USER
    }.to_json
  end

  begin
    table = Table.find(table_id)
  rescue ActiveRecord::RecordNotFound
    return 409, {
      status: 1,
      error: ErrorText::NO_TABLE
    }.to_json
  end

  restaurant = table.restaurant
  if !restaurant.is_time_between_work_hours?(start_at, stop_at)
    return 409, {
      status: 1,
      error: ErrorText::RESTAURANT_CLOSED
    }.to_json
  end

  reservations_in_time =\
    Reservation
    .includes(table: [:restaurant])
    .where("start_at <= ?", start_at)
    .where("stop_at > ?", start_at)
    .or(
      Reservation
      .includes(table: [:restaurant])
      .where("start_at <= ?", stop_at)
      .where("stop_at >= ?", stop_at)
    )
    .all()

  reservations_in_time.each {
    |r|
    if r.table_id == table_id
      return 409, {
        status: 1,
        error: ErrorText::TABLE_RESERVED
      }.to_json
    end
    if r.user_id == user_id && r.table.restaurant.id != restaurant.id
      return 409, {
        status: 1,
        error: ErrorText::USER_SECOND_RESTAURANT
      }.to_json
    end
  }

  record = Reservation.create(json_body)
  if !(record.valid?)
    return 409, {
      status: 1,
      error: ErrorText::INVALID
    }.to_json
  end
  return 201, {
    status: 0,
    data: {
      reservation: record.to_json()
    }
  }.to_json
end

put '/api/reservations/:id' do
  request.body.rewind
  json_body = JSON.parse(request.body.read)
  json_body.slice!('start_at', 'stop_at')

  start_at = Time.at(json_body['start_at'])
  stop_at = Time.at(json_body['stop_at'])

  json_body['start_at'] = start_at
  json_body['stop_at'] = stop_at

  begin
    record = Reservation.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    return 404, {
      status: 1,
      error: ErrorText::NOT_FOUND
    }.to_json
  end

  restaurant = record.table.restaurant
  if !restaurant.is_time_between_work_hours?(start_at, stop_at)
    return 409, {
      status: 1,
      error: ErrorText::RESTAURANT_CLOSED
    }.to_json
  end

  exists_other_table_reservation =\
    Reservation
    .includes(table: [:restaurant])
    .where("start_at <= ?", start_at)
    .where("stop_at > ?", start_at)
    .or(
      Reservation
      .includes(table: [:restaurant])
      .where("start_at <= ?", stop_at)
      .where("stop_at >= ?", stop_at)
    )
    .where(table_id: record.table_id)
    .where.not(id: record.id)
    .exists?()

  if exists_other_table_reservation
    return 409, {
      status: 1,
      error: ErrorText::TABLE_RESERVED
    }.to_json
  end

  record.update(json_body)
  return 201, {
    status: 0,
    data: {
      reservation: record.to_json()
    }
  }.to_json
end

delete '/api/reservations/:id' do
  begin
    record = Reservation.find(params[:id])
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
