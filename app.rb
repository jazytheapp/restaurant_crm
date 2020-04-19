# frozen_string_literal: true

require 'sinatra'
require 'sinatra/activerecord'
require 'active_support/core_ext/hash'
require 'json'

require 'rack/contrib'
require 'byebug'

require 'zeitwerk'

APP_LOADER = Zeitwerk::Loader.new
%w[
  models
  controllers
].each(&APP_LOADER.method(:push_dir))
APP_LOADER.enable_reloading
APP_LOADER.setup
APP_LOADER.eager_load
