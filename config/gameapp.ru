require_relative '../boot'

require 'sinatra'

map '/' do
  run GameApp
end
