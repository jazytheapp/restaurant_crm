require 'sinatra'
require 'sinatra/activerecord'
require 'active_support/core_ext/hash'
require 'json'

require 'sinatra/reloader' if development?

require './models/restaurant'
require './models/table'
require './models/user'
require './models/reservation'

require './controllers/base'
require './controllers/index_controller'
require './controllers/restaurant_controller'
require './controllers/table_controller'
require './controllers/user_controller'
require './controllers/reservation_controller'
