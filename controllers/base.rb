before do
  content_type :json
end

class ErrorText
  NOT_FOUND = 'Not Found'
  NOT_UNIQUE = 'Not Unique'
  INVALID = 'Invalid field(s)'
end
