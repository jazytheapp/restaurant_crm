before do
  content_type :json
end

class ErrorText
  NOT_FOUND = 'Not Found'
  NOT_UNIQUE = 'Not Unique'
  INVALID = 'Invalid field(s)'
  INVALID_TIME = 'Invalid time'
  NO_USER = 'User not found'
  NO_TABLE = 'Table not found'
  RESTAURANT_CLOSED = 'The restaurant is closed at this time'
  TABLE_RESERVED = 'Table reserved for this time'
  USER_SECOND_RESTAURANT = 'The user has already reserved a table in another restaurant'
end
