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

  def check_state
    # First check column
    col_winner = GameBoard.check_consecutive(@board)
    if col_winner
      return {"state" => "winner", "winning_player" => col_winner}
    end

    # Second check rows
    row_winner = GameBoard.check_consecutive(@board.transpose)
    if row_winner
      return {"state" => "winner", "winning_player" => row_winner}
    end

    # Third check diagonals
    diagonals = GameBoard.create_diagonals(@board)
    diagonal_winner = GameBoard.check_consecutive(diagonals)
    if diagonal_winner
      return {"state" => "winner", "winning_player" => diagonal_winner}
    end

    # And counter diagonals
    counter_diagonals = GameBoard.create_counter_diagonals(@board)
    counter_diagonal_winner = GameBoard.check_consecutive(counter_diagonals)
    if counter_diagonal_winner
      return {"state" => "winner", "winning_player" => counter_diagonal_winner}
    end

    # Last check for draws
    if GameBoard.full_board?(@board)
      return {"state" => "draw"}
    end

    return {}
  end

  def self.create_diagonals(board)
    (0..board.size - WINNING_COUNT).map do |i|
      (0..board[i].size - WINNING_COUNT).map do |j|
        (0..WINNING_COUNT-1).map do |k|
          board[i+k][j+k]
        end
      end
    end.first # Avoid the tertiary nested array
  end

  def self.create_counter_diagonals(board)
    (0..board.size - WINNING_COUNT).map do |i|
      (0..board[i].size - WINNING_COUNT).map do |j|
        (0..WINNING_COUNT-1).map do |k|
          board[i+k][board[i].size-1-j-k]
        end
      end
    end.first # Avoid the tertiary nested array
  end

  def self.full_board?(board)
    board.each do |col|
      if col.include?(nil)
        return false
      end
    end

    return true
  end

  def self.from_json(raw_object)
    board = JSON.load(raw_object)

    rows = board.length
    columns = board[0].length

    new_board = self.new(rows, columns)
    new_board.board = board

    return new_board
  end

  def self.check_consecutive(board)
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
