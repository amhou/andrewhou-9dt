require 'bundler/setup'
Bundler.require

APP_ENV = ENV['APP_ENV']

require_relative './initializers/database.rb'

Dir["./app/**/*.rb"].each {|file| require file }
