require 'spec_helper'

describe Move do
  it "present a pretty Move" do
    m = build(:move).save
    expect(m.present).to eq(
      {
        "type" => "MOVE",
        "player" => "player1",
        "column" => 4
      }
    )
  end
end


