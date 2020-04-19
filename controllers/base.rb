# frozen_string_literal: true

class Base < Sinatra::Base
  use Rack::JSONBodyParser

  configure :development do
    set :dump_errors, false
    set :raise_errors, false
    set :show_exceptions, false
  end

  before do
    content_type :json
  end

  error ActiveRecord::RecordNotFound do |e|
    status 404
    {
      status: 1,
      error: ErrorText::NOT_FOUND,
      message: e
    }.to_json
  end

  error ActiveRecord::RecordNotUnique do |e|
    status 409
    {
      status: 1,
      error: ErrorText::NOT_UNIQUE,
      message: e
    }.to_json
  end

  error ActiveRecord::RecordInvalid do |e|
    status 409
    {
      status: 1,
      error: ErrorText::INVALID,
      message: e
    }.to_json
  end
end

class ErrorText
  NOT_FOUND = 'Not Found'
  NOT_UNIQUE = 'Not Unique'
  INVALID = 'Invalid field(s)'
end
