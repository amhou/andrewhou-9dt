FactoryBot.define do
  factory :player1 do
    id {"player1"}
  end

  factory :player2 do
    id {"player2"}
  end

  factory :game do
    id {"some_id"}
    state {"IN PROGRESS"}
    player_order {"[\"player1\",\"player2\"]"}
    next_player {"player1"}
    board {"[[null,null,null,null],[null,null,null,null],[null,null,null,null],[null,null,null,null]]"}
  end

  factory :move do
    type {"MOVE"}
    m_column { 4 }
    player_id { "player1" }
  end

  factory :game_board do
    transient do
      rows { 4 }
      columns { 4 }
      board {
        [["player1","player1","player1","player1"],
         [nil,nil,nil,nil],
         [nil,nil,nil,nil],
         [nil,nil,nil,nil]]
      }
    end

    initialize_with { new(attributes.merge(rows: rows, columns: columns, board: board)) }
  end
end
