class GameApp < Sinatra::Base
  get '/' do
    status 200
    return "Drop Token Game"
  end

  get "/status" do
    status 200
    return {
      status: 'success'
    }.to_json
  end
end
