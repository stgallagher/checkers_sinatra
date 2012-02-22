require 'spec_helper'

describe Evaluation do
  before(:each) do
    view = Gui.new
    @game = Game.new(view)
    @b = Board.new
    @eval = Evaluation.new
    @full_board = @b.create_board
    @clear_board = @b.create_test_board
  end

  it "should calculate the value of a checker based on its position" do
    @b.add_checker(@clear_board, :red, 2, 0)
    @eval.calculate_value(@clear_board[2][0], :red).should == 20
  end

  it "should have an evaluation chooser that directs calls to the appropiate evaluation method" do
    evaluation_method_choice = 2
    @eval.should_receive(:evaluate_board2)
    @eval.evaluation_chooser(evaluation_method_choice, @full_board)
  end

  it "should calculate the value of the board based on checkers presence and position" do
    @b.add_checker(@clear_board, :red, 4, 6)
    @b.add_checker(@clear_board, :red, 2, 0)
    @b.add_checker(@clear_board, :black, 1, 5)
    @b.add_checker(@clear_board, :black, 7, 5)
    @clear_board[7][5].make_king
    @eval.evaluate_board1(@clear_board).should == -26
  end

  it "should calculate the value of the board based on number of checkers left" do
    @b.add_checker(@clear_board, :red, 4, 6)
    @b.add_checker(@clear_board, :red, 2, 0)
    @b.add_checker(@clear_board, :black, 1, 5)
    @b.add_checker(@clear_board, :black, 7, 7)
    @b.add_checker(@clear_board, :black, 7, 5)
    @eval.evaluate_board2(@clear_board).should == -1
  end
end
