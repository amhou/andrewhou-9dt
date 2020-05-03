require 'spec_helper'

describe GameBoard do
  let(:game_board) { GameBoard.new(4,4) }

  it "raises an error for invalid inputs" do
    gb = game_board
    expect { gb.move(-1, "player1") }.to raise_error(
      ArgumentError,
      "Invalid move. Column must be greater than 0."
    )

    expect { gb.move(5, "player1") }.to raise_error(
      ArgumentError,
      "Invalid move. Column must be less than 4."
    )

    gb.board[0] = ["full","full","full","full"]
    expect { gb.move(0, "player1") }.to raise_error(
      ArgumentError,
      "Invalid move. Column is full."
    )
  end

  it "correctly appends to a column" do
    gb = game_board
    gb.board[0] = ["player1","player1",nil,nil]
    expect(gb.move(0, "player1")).to eq(
      [["player1","player1","player1",nil],
       [nil,nil,nil,nil],
       [nil,nil,nil,nil],
       [nil,nil,nil,nil]
      ]
    )

    expect(gb.move(3, "player2")).to eq(
      [["player1","player1","player1",nil],
       [nil,nil,nil,nil],
       [nil,nil,nil,nil],
       ["player2",nil,nil,nil]
      ]
    )
  end

  it "correctly creates a list of diagonals" do
    board = [["player1",nil,nil,nil,nil],
             [nil,"player1",nil,nil,nil],
             [nil,nil,"player1",nil,nil],
             [nil,nil,nil,"player1",nil]
    ]
    expect(GameBoard.create_diagonals(board)).to eq(
      [["player1","player1","player1","player1"],
       [nil,nil,nil,nil]]
    )
  end

  it "correctly creates a list of counter diagonals" do
    board = [["player1",nil,nil,nil,nil],
             [nil,"player1",nil,nil,nil],
             [nil,nil,"player1",nil,nil],
             [nil,nil,nil,"player1",nil]
    ]
    expect(GameBoard.create_counter_diagonals(board)).to eq(
      [[nil,nil,"player1",nil],
       [nil,nil,nil,nil]]
    )
  end

  it "correctly determines if a board is full" do
    board = [["player1","player1","player1","player1"],
             ["player1","player1","player1","player1"],
             ["player1","player1","player1","player1"],
             ["player1","player1","player1","player1"]]
    expect(GameBoard.full_board?(board)).to be true

    board = [["player1","player1","player1","player1"],
             ["player1","player1","player1","player1"],
             ["player1","player1","player1","player1"],
             ["player1","player1","player1",nil]]
    expect(GameBoard.full_board?(board)).to be false
  end

  it "correctly determines if there is a column winner" do
    board = [["player1",nil,nil,nil,nil],
             [nil,"player1",nil,nil,nil],
             [nil,nil,"player1",nil,nil],
             ["player1","player1","player1","player1","player1"]]
    expect(GameBoard.check_consecutive(board)).to eq("player1")

    board = [["player1",nil,nil,nil,nil],
             [nil,"player1",nil,nil,nil],
             [nil,nil,"player1",nil,nil],
             ["player1","player1","player1","player2","player2"]]
    expect(GameBoard.check_consecutive(board)).to eq(nil)
  end

  it "correctly checks state" do
    gb = game_board
    gb.board = [["player1",nil,nil,nil,nil],
                [nil,"player1",nil,nil,nil],
                [nil,nil,"player1",nil,nil],
                ["player1","player1","player1","player2","player2"]]

    expect(gb.check_state).to eq({})

    # Column
    gb = game_board
    gb.board = [["player1",nil,nil,nil,nil],
                [nil,"player1",nil,nil,nil],
                [nil,nil,"player1",nil,nil],
                ["player1","player1","player1","player1","player1"]]

    expect(gb.check_state).to eq({"state" => "winner", "winning_player" => "player1"})

    # Diagonal
    gb = game_board
    gb.board = [["player1",nil,nil,nil,nil],
                [nil,"player1",nil,nil,nil],
                [nil,nil,"player1",nil,nil],
                ["player1","player2","player1","player1","player1"]]

    expect(gb.check_state).to eq({"state" => "winner", "winning_player" => "player1"})

    # Row
    gb = game_board
    gb.board = [["player1",nil,nil,nil,nil],
                ["player1","player1",nil,nil,nil],
                ["player1",nil,"player1",nil,nil],
                ["player1","player1","player2","player2","player2"]]

    expect(gb.check_state).to eq({"state" => "winner", "winning_player" => "player1"})
    #
    # Draw
    gb.board = [["player1","player1","player6","player1"],
             ["player3","player5","player1","player1"],
             ["player1","player9","player1","player1"],
             ["player1","player1","player1","player7"]]
    expect(gb.check_state).to eq({"state" => "draw"})
  end
end
