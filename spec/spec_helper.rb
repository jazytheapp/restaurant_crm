ENV['APP_ENV'] = 'test'

require './app'
require 'rspec'
require 'rack/test'

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.before(:all) do
    load "./db/schema.rb"
  end
  config.before(:each) do
    tables = [
      'restaurants',
    ]
    tables.each do |table_name|
      ActiveRecord::Base.connection.execute("Delete from #{table_name}")
      ActiveRecord::Base.connection.execute("DELETE FROM SQLITE_SEQUENCE WHERE name='#{table_name}'")
    end
  end 
end
