class Game < Sequel::Model
  one_to_many :moves
  many_to_many :players

  def ordered_moves
    return moves_dataset.order(:m_number)
  end

  def get_next_player
    p_order = JSON.load(player_order)
    player_index = p_order.index(next_player)

    return p_order[(player_index + 1) % p_order.length]
  end
end
