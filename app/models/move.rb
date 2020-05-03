class Move < Sequel::Model
  one_to_one :player
  many_to_one :game

  def present
    output = {"type" => type, "player" => player_id}

    if m_column
      output["column"] = m_column
    end

    return output
  end
end
