require 'sinatra'
require 'sinatra/activerecord'
require 'active_support/core_ext/hash'
require 'json'

if ENV['APP_ENV'] != 'test'
  require 'sinatra/reloader'
end

require './models/restaurant'

require './controllers/base'
require './controllers/index_controller'
require './controllers/restaurant_controller'
