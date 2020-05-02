require 'pry'
class Game < Sequel::Model
  def validate
    # Return whether or not a game is valid.
    super

    errors.add(:players, "cannot be empty") if !players || JSON.load(players).empty?
    errors.add(:players, "must be an array of String IDs") if JSON.load(players).map do |p|
      p.class == String
    end.include?(false)
    errors.add(:players, "must be unique") if JSON.load(players).uniq.length != JSON.load(players).length
    errors.add(:g_columns, "columns must be a number greater than 0") if g_columns.class != Integer || g_columns <= 0
    errors.add(:g_rows, "rows must be a number greater than 0") if g_rows.class != Integer || g_rows <= 0
  end
end
