class GameBoard
  attr_accessor :board, :rows, :columns

  WINNING_COUNT = 4

  def initialize(rows, columns)
    @rows = rows
    @columns = columns

    # Initialize an empty game board
    @board = Array.new(@columns) { Array.new(@rows, nil) }
  end

  def to_json
    return @board.to_json
  end

  def move(m_column, player_id)
    if m_column < 0
      raise ArgumentError, "Invalid move. Column must be greater than 0."
    end

    if m_column >= rows
      raise ArgumentError, "Invalid move. Column must be less than #{@columns}."
    end

    # Compact to remove nil values
    if @board[m_column].compact.length >= @rows
      raise ArgumentError, "Invalid move. Column is full."
    end

    moved_column = @board[m_column].compact.append(player_id)
    while moved_column.length < rows
      moved_column.append(nil)
    end

    @board[m_column] = moved_column

    return @board
  end

  def check_state(player_id)
    # First check column
    player_count = 0
    (0..@columns).each do |c|
      (0..@rows).each do |r|
        if @board[c][r] == player_id
          player_count += 1
        else
          player_count = 0
        end

        if player_count >= 4
          return {"state": "winner", "winning_player": player_id}
        end
      end
    end

    # Second check rows
    player_count = 0
    (0..@rows).each do |r|
      (0..@columns).each do |c|
        if @board[c][r] == player_id
          player_count += 1
        else
          player_count = 0
        end

        if player_count >= 4
          return {"state": "winner", "winning_player": player_id}
        end
      end
    end

    # Third check diagonals
    # (0..@columns - WINNING_COUNT).each do |c|
    #   (0..@rows - WINNING_COUNT).each do |r|
    #     diagonal = create_diagonal(c,r)
    #     if diagonal.uniq.size == 1 && diagonal
    #     end


    # Last check for draws
    return {"state": "draw"}
  end

  def create_diagonals(c_idx, r_idx)
    diagonals = []

    (c_idx..(c_idx + @columns - WINNING_COUNT)).each_with_index do |i,j|
      diagonals << @board[i,r_idx+j]
    end

    return diagonals
  end

  def self.from_json(raw_object)
    board = JSON.load(raw_object)

    rows = board.length
    columns = board[0].length

    new_board = self.new(rows, columns)
    new_board.board = board

    return new_board
  end

  def check_consecutive(board)
    board.each do |column|
      # Iterate consecutive elements
      i = column.each_cons(WINNING_COUNT).find do |i|
        i.uniq.size == 1 && i.first != nil
      end

      return i.first unless i.nil?
    end

    return nil
  end
end
