class GameApp < Sinatra::Base
  helpers do
    def player(player_id)
      p = Player.find(id: player_id)

      if p.nil?
        p = Player.new
        p.id = player_id
        p.save
      end

      return p
    end
  end

  # Return all in-progress games
  # Example:
  # { "games": ["gameid1", "gameid2"] }
  get '/drop_token' do
    in_progress_games = Game.where(state: "IN_PROGRESS")

    output = {"games": in_progress_games.map(&:game_id)}

    status 200
    return output.to_json
  end

  # Create a new game.
  # Input:
  # { "players": ["player1", "player2"], "columns": 4, "rows" 4 }
  #
  # Output:
  # { "gameId": "some_string_token" }
  post "/drop_token" do
    input = JSON.load(request.body.read)

    # Validate input
    required_input = ["players", "columns", "rows"]
    required_input.each do |k|
      if !input.has_key?(k)
        halt 400, "Missing required parameter #{k}"
      end
    end

    if input['players'].uniq.length != input['players'].length
      halt 400, "Players must be unique"
    end

    if input['players'].length < 2
      halt 400, "Must have at least 2 players"
    end

    if input["columns"].class != Integer || input["columns"] <= 0
      halt 400, "columns must be a number greater than 0"
    end

    if input["rows"].class != Integer || input["rows"] <= 0
      halt 400, "rows must be a number greater than 0"
    end

    # Create players
    game_players = []
    input["players"].each do |p_id|
      game_players.append(player(p_id))
    end

    # Create game
    g = Game.new
    g.id = SecureRandom.uuid
    g.board = GameBoard.new(input["rows"], input["columns"]).to_json
    g.player_order = JSON.dump(input["players"])
    g.next_player = game_players[0].id

    g.save

    # Associate players to game
    game_players.each do |gp|
      g.add_player(gp)
    end

    status 200
    return { "gameId": g.id }.to_json
  end

  # Get the state of the game.
  # Output:
  # { "players": ["player1", "player2"], "state": "DONE/IN_PROGRESS", "winner" "player1" }
  get "/drop_token/:game_id" do
    game_id = params["game_id"]

    if game_id.class != String
      halt 400, {"message": "game"}
    end

    g = Game.where(id: game_id).first

    if g.nil?
      halt 404, "Game not found"
    end

    output = {
      "players": g.players.map(&:id),
      "state": g.state
    }

    if g.state == "DONE"
      # Winner may be null if the game is a draw
      output["winner"] = g.winner
    end

    status 200
    return output.to_json
  end

  # Get (sub) list of the moves played.
  # Output:
  # {
  #   "moves": [
  #     {"type": "MOVE", "player": "player1", "column": 1},
  #     {"type": "QUIT", "player": "player2"}
  #   ]
  # }
  get "/drop_token/:game_id/moves" do
    game_id = params["game_id"] # game_id will always be a String in Sinatra

    g = Game.where(id: game_id).first

    if g.nil?
      halt 404, "Game not found"
    end

    output = {"moves": g.ordered_moves.map{|m| m.present}}

    status 200
    return output.to_json
  end

  # Post a move
  # Input:
  # { "column": 2 }
  #
  # Output:
  # { "move": "{game_id}/moves/{move_number}" }
  post "/drop_token/:game_id/:player_id" do
    game_id = params["game_id"] # game_id will always be a String in Sinatra
    player_id = params["player_id"]

    g = Game.where(id: game_id).first
    p = Player.where(id: player_id).first

    if g.nil?
      halt 404, "Game not found"
    end

    if !g.players.map(&:id).include?(player_id)
      halt 404, "Player not in game"
    end

    if g.next_player != player_id
      halt 409, "It's not Player #{player_id}'s turn! Player #{g.next_player} is next"
    end

    input = JSON.load(request.body.read)

    if input["column"].nil?
      halt 400, "Missing required parameter column"
    end

    # Load GameBoard from database
    gb = GameBoard.from_json(g.board)

    if input["column"] < 0 || input["column"] > gb.columns
      halt 400, "Invalid move. Column must be greater than 0 and less than or equal to #{gb.columns - 1}"
    end

    # Make the actual move
    begin
      g.board = gb.move(input["column"], player_id).to_json
      m = Move.new
      m.type = "MOVE"
      m.m_column = input["column"]

      if g.ordered_moves.last
        m.m_number = g.ordered_moves.last.m_number + 1
      else
        m.m_number = 1
      end

      m.save

      # Associate the move with the game and the player
      g.add_move(m)
      p.add_move(m)

      # Update the game, checking for winners, draws, and next players
      # We only need to check if the current player is a winner, as
      # they're the one that made the most recent move.
      gb_state = gb.check_state
      if gb_state["state"] == "winner"
        g.state = "DONE"
        g.winner = gb_state["winning_player"]
        g.next_player = nil
      elsif gb_state["state"] == "draw"
        g.state = "DONE"
        g.next_player = nil
      else
        g.next_player = g.get_next_player
      end
      g.save
    rescue ArgumentError => e
      halt 400, e.message
    end

    return {"move": "#{game_id}/moves/#{m.m_number}"}.to_json
  end

  # Return the move
  # Output:
  # { "type": "MOVE", "player": "player1", "column" 2 }
  get "/drop_token/:game_id/moves/:move_number" do
    game_id = params["game_id"] # game_id will always be a String in Sinatra
    m_number = params["move_number"]

    g = Game.where(id: game_id).first
    m = Move.where(game_id: game_id, m_number: m_number).first

    if g.nil?
      halt 404, "Game not found"
    end

    if m.nil?
      halt 404, "Move not found"
    end

    status 200
    return m.present.to_json
  end

  # Player quits from game
  delete "/drop_token/:game_id/:player_id" do
    game_id = params["game_id"] # game_id will always be a String in Sinatra
    player_id = params["player_id"]

    g = Game.where(id: game_id).first
    p = Player.where(id: player_id).first

    if g.nil?
      halt 404, "Game not found"
    end

    if !g.players.map(&:id).include?(player_id)
      halt 404, "Player not in game"
    end

    if g.state == "DONE"
      halt 410, "Game is already DONE"
    end

    m = Move.new
    m.type = "QUIT"
    g.add_move(m)
    p.add_move(m)

    # Move to the next player
    if g.next_player == player_id
      g.next_player = g.get_next_player
    end

    p_order = JSON.load(g.player_order)
    p_order.delete(player_id)
    g.player_order = JSON.dump(p_order)

    # Check how many players are left
    if p_order.length == 1
      g.state = "DONE"
      g.winner = p_order.first
    end

    g.save

    g.remove_player(player_id)

    status 202
    return
  end

  get "/status" do
    status 200
    return {
      status: 'success'
    }.to_json
  end
end
