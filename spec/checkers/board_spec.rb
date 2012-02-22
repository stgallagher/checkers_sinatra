require 'spec_helper'


describe Board do
    
  before(:each) do 
    @board = Board.new
    @clear_board = @board.create_test_board
  end
  
  it "should create an 8 X 8 board" do
    @clear_board.size.should    == 8
    @clear_board[3].size.should == 8
  end

  it "should populate checkers in the right position" do
    @new_board = @board.populate_checkers(@clear_board)
    @new_board[0][4].color.should == :red
    @new_board[1][3].color.should == :red
    @new_board[2][0].color.should == :red
    @new_board[5][7].color.should == :black
    @new_board[6][4].color.should == :black
    @new_board[7][3].color.should == :black
  end

  it "should add a checker to the board" do
    @board.add_checker(@clear_board, :red, 3, 3)
    @clear_board[3][3].class.should == Checker
    @clear_board[3][3].color.should == :red
  end

  it "should place a checker on the board" do
    new_checker = Checker.new(3, 3, :red)
    @board.place_checker_on_board(@clear_board, new_checker)
    @clear_board[3][3].class.should == Checker
    @clear_board[3][3].color.should == :red
  end
  
  it "should king checkers if they're in the last row" do
    @board.add_checker(@clear_board, :red, 7, 5)
    @board.add_checker(@clear_board, :black, 0, 3)
    @clear_board[7][5].is_king?.should == false
    @clear_board[0][3].is_king?.should == false
    Board.king_checkers_if_necessary(@clear_board)
    @clear_board[7][5].is_king?.should == true
    @clear_board[0][3].is_king?.should == true
  end

  it "should remove a checker that has been jumped" do
    @board.add_checker(@clear_board, :red, 3, 3)
    @clear_board[3][3].color.should == :red
    Board.remove_jumped_checker(@clear_board, 4, 4, 2, 2)
    @clear_board[3][3].should == nil
  end
  
  it "should remove a checker from the board" do
    @board.add_checker(@clear_board, :red, 3, 3)
    @clear_board[3][3].color.should == :red
    @board.remove_checker(@clear_board, 3, 3)
    @clear_board[3][3].should == nil
  end
end

