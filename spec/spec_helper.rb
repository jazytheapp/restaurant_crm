# frozen_string_literal: true

ENV['APP_ENV'] = 'test'

require './app'
require 'rspec'
require 'rack/test'
require 'database_cleaner/active_record'

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.before(:all) do
    load './db/schema.rb'
  end
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end
  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end
