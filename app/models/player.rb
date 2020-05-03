class Player < Sequel::Model
  one_to_many :moves
  many_to_many :games

  def validate
    super

    errors.add(:id, "cannot be empty") if !id || id.empty?
    errors.add(:id, "must be a string") if id.class != String
  end
end
