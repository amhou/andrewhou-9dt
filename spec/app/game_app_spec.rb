require 'spec_helper'

describe GameApp do
  let(:ga) { game_app }

  describe '/status' do
    it "should return 200" do
      r = ga.get "/status"
      expect(r.status).to eq 200
    end
  end

  describe 'GET /drop_token' do
    it "should return all in-progress games" do
      game1 = build(:game, id: "some_game").save
      game2 = build(:game, id: "some_other_game").save

      r = ga.get '/drop_token'
      expect(JSON.load(r.body)).to eq(
        "games" => ["some_game", "some_other_game"]
      )
    end
  end

  describe 'POST /drop_token' do
    it "should validate game creation parameters exist" do
      r = ga.post "/drop_token"
      expect(r.status).to eq 400

      r = ga.post "/drop_token", '{"players": ["player1", "player2"]}'
      expect(r.status).to eq 400
      expect(r.body).to eq('Missing required parameter columns')

      r = ga.post "/drop_token", '{"players": ["player1", "player1"], "columns": 4, "rows": 4}'
      expect(r.status).to eq 400
      expect(r.body).to eq('Players must be unique')

      r = ga.post "/drop_token", '{"players": ["player1", "player2"], "columns": 4, "rows": 3}'
      expect(r.status).to eq 400
      expect(r.body).to eq('rows must be a number greater than 3')
    end

    it "should create a Game with associated players" do
      r = ga.post "/drop_token", '{"players": ["player1", "player2"], "columns": 4, "rows": 4}'
      expect(r.status).to eq 200
      g_id = JSON.load(r.body)["gameId"]
      g = Game.where(id: g_id).first
      expect(JSON.load(g.board).length).to eq(4)
      expect(JSON.load(g.board)[0].length).to eq(4)
      expect(JSON.load(g.player_order)).to eq(["player1","player2"])
      expect(g.next_player).to eq("player1")

      expect(g.players.size).to eq(2)
      expect(g.moves).to eq([])
    end
  end

  describe 'GET /drop_token/:game_id' do
    it "should 404 if the game isn't known" do
      r = ga.get "/drop_token/some_id"
      expect(r.status).to eq 404
    end

    it "should get the state of a provided game" do
      r = ga.post "/drop_token", '{"players": ["player1", "player2"], "columns": 4, "rows": 4}'
      expect(r.status).to eq 200
      g_id = JSON.load(r.body)["gameId"]

      r = ga.get "/drop_token/#{g_id}"
      expect(r.status).to eq 200
      expect(JSON.load(r.body)).to eq(
        {
          "players" => ["player1", "player2"],
          "state" => "IN_PROGRESS"
        }
      )
    end
  end

  describe 'GET /drop_token/:game_id/moves' do
    it "should 404 if the game isn't known" do
      r = ga.get "/drop_token/some_id/moves"
      expect(r.status).to eq 404
    end

    it "should return a list of moves" do
      r = ga.post "/drop_token", '{"players": ["player1", "player2"], "columns": 4, "rows": 4}'
      expect(r.status).to eq 200
      g_id = JSON.load(r.body)["gameId"]

      ga.delete "/drop_token/#{g_id}/player1"

      r = ga.get "/drop_token/#{g_id}/moves"
      expect(r.status).to eq 200
      expect(JSON.load(r.body)).to eq(
        {"moves" => [{"type" => "QUIT", "player" => "player1"}]}
      )
    end
  end

  describe 'POST /drop_token/:game_id/:player_id' do
    it "should 404 if the game isn't known" do
      r = ga.post "/drop_token/some_id/player1"
      expect(r.status).to eq 404
    end

    it "should 404 if the player isn't in the game" do
      r = ga.post "/drop_token", '{"players": ["player1", "player2"], "columns": 4, "rows": 4}'
      expect(r.status).to eq 200
      g_id = JSON.load(r.body)["gameId"]

      r = ga.post "/drop_token/#{g_id}/player3"
      expect(r.status).to eq 404
    end

    it "should 409 if isn't the player's move" do
      r = ga.post "/drop_token", '{"players": ["player1", "player2"], "columns": 4, "rows": 4}'
      expect(r.status).to eq 200
      g_id = JSON.load(r.body)["gameId"]

      r = ga.post "/drop_token/#{g_id}/player2"
      expect(r.status).to eq 409
    end

    it "should return the move number for a successful move" do
      r = ga.post "/drop_token", '{"players": ["player1", "player2"], "columns": 4, "rows": 4}'
      expect(r.status).to eq 200
      g_id = JSON.load(r.body)["gameId"]

      r = ga.post "/drop_token/#{g_id}/player1", '{"column": 3}'
      expect(r.status).to eq 200
      expect(JSON.load(r.body)).to eq({"move" => "#{g_id}/moves/1"})
    end
  end

  describe 'GET /drop_token/:game_id/moves/:move_number' do
    it "should 404 if the game isn't known" do
      r = ga.post "/drop_token/some_id/moves/1"
      expect(r.status).to eq 404
    end

    it "should return the move" do
      r = ga.post "/drop_token", '{"players": ["player1", "player2"], "columns": 4, "rows": 4}'
      expect(r.status).to eq 200
      g_id = JSON.load(r.body)["gameId"]
      r = ga.post "/drop_token/#{g_id}/player1", '{"column": 3}'

      r = ga.get "/drop_token/#{g_id}/moves/1"
      expect(r.status).to eq 200
      expect(JSON.load(r.body)).to eq(
        {"type" => "MOVE", "player" => "player1", "column" => 3}
      )
    end
  end

  describe 'DELETE /drop_token/:game_id/:player_id' do
    it "should 404 if the game isn't known" do
      r = ga.delete "/drop_token/some_id/some_player"
      expect(r.status).to eq 404
    end

    it "should 404 if the player isn't known" do
      r = ga.post "/drop_token", '{"players": ["player1", "player2"], "columns": 4, "rows": 4}'
      expect(r.status).to eq 200
      g_id = JSON.load(r.body)["gameId"]

      r = ga.delete "/drop_token/#{g_id}/some_player"
      expect(r.status).to eq 404
    end

    it "should 410 if the game is already done" do
      r = ga.post "/drop_token", '{"players": ["player1", "player2"], "columns": 4, "rows": 4}'
      expect(r.status).to eq 200
      g_id = JSON.load(r.body)["gameId"]
      g = Game.where(id: g_id).first
      g.state = "DONE"
      g.save

      r = ga.delete "/drop_token/#{g_id}/player1"
      expect(r.status).to eq 410
    end

    it "should successfuly remove the player, performing it as a move" do
      r = ga.post "/drop_token", '{"players": ["player1", "player2"], "columns": 4, "rows": 4}'
      expect(r.status).to eq 200
      g_id = JSON.load(r.body)["gameId"]

      r = ga.delete "/drop_token/#{g_id}/player1"
      expect(r.status).to eq 202

      g = Game.where(id: g_id).first
      expect(g.players.size).to eq(1)
      expect(g.moves.size).to eq(1)
    end
  end
end
