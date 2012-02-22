require 'spec_helper'

describe UserInput do

  it  "should parse a move request into an integer array format" do
    input = UserInput.new
    input.translate_move_request_to_coordinates("2, 3, 4, 5").should == [2, 3, 4, 5]
  end
end
