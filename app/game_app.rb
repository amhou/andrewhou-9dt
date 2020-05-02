class GameApp < Sinatra::Base
  helpers do
    def player
      return Player.find_or_create(player_id: player_id)
    end
  end

  get '/drop_token' do
    # Return all in-progress games
    # Example:
    # { "games": ["gameid1", "gameid2"] }
    in_progress_games = Game.where(state: "IN_PROGRESS")

    output = {"games": in_progress_games.map(&:game_id)}

    status 200
    return output.to_json
  end

  post "/drop_token" do
    # Create a new game.
    # Input:
    # { "players": ["player1", "player2"], "columns": 4, "rows" 4 }
    #
    # Output:
    # { "gameId": "some_string_token" }
    input = JSON.load(request.body.read)

    required = ["players", "columns", "rows"]
    required.each do |k|
      if !input.has_key?(k)
        halt 400, "Missing required parameter #{k}"
      end
    end

    g = Game.new
    g.game_id = SecureRandom.uuid
    g.players = JSON.dump(input["players"])
    g.g_columns = input["columns"]
    g.g_rows = input["rows"]

    unless g.valid?
      halt 400, g.errors.to_json
    end

    g.save

    status 200
    return { "gameId": g.game_id }.to_json
  end

  get "/drop_token/:game_id" do
    # Get the state of the game.
    # Output:
    # { "players": ["player1", "player2"], "state": "DONE/IN_PROGRESS", "winner" "player1" }
    game_id = params["game_id"]

    if game_id.class != String
      halt 400, {"message": "game"}
    end

    g = Game.where(game_id: game_id).first

    output = {
      "players": JSON.load(g.players),
      "state": g.state
    }

    if g.state == "DONE"
      # Winner may be null if the game is a draw
      output["winner"] = g.winner
    end

    status 200
    return output.to_json
  end

  get "/drop_token/:game_id/moves" do
    # Get (sub) list of the moves played.
    # Output:
    # {
    #   "moves": [
    #     {"type": "MOVE", "player": "player1", "column": 1},
    #     {"type": "QUIT", "player": "player2"}
    #   ]
    # }
  end

  post "/drop_token/:game_id/:player_id" do
    # Post a move
    # Input:
    # { "column": 2 }
    #
    # Output:
    # { "move": "{game_id}/moves/{move_number}" }
  end

  get "/drop_token/:game_id/moves/:move_number" do
    # Return the move
    # Output:
    # { "type": "MOVE", "player": "player1", "column" 2 }
  end

  delete "/drop_token/:game_id/:player_id" do
    # Player quits from game
  end

  get "/status" do
    status 200
    return {
      status: 'success'
    }.to_json
  end
end
