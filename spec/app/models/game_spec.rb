require 'spec_helper'

describe Game do
  it "should properly get the next player" do
    g = build(:game).save
    expect(g.get_next_player).to eq("player2")
  end
end
