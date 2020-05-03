require 'spec_helper'

describe Player do
  it "raise an error for invalid inputs" do
    p = Player.new
    p.id = ''
    expect { p.save }.to raise_error(
      Sequel::ValidationFailed,
      "id cannot be empty"
    )
  end
end

