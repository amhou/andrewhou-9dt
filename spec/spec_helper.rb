APP_ENV='test'

require 'rspec'
require 'factory_bot'
require 'pry'
require 'rack/test'
require './boot'

RSpec.configure do |config|
  config.order = 'random'
  config.color = 'true'

  config.before(:each) do
    DB.from(Game.table_name).delete
  end

  config.include FactoryBot::Syntax::Methods
  config.before(:suite) do
    FactoryBot.find_definitions
  end
end

def game_app
  Rack::Test::Session.new(Rack::MockSession.new(GameApp.new))
end
