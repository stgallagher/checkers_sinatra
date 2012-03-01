require_relative 'helper'
require_relative 'lib/checkers/board'
require_relative 'lib/checkers/checker'

describe "helper" do

  before :each do
    @h = Helper.new
  end

  describe "board_to_game_state_string" do
    it "translates board objects into game state strings" do
      board = Board.new
      game_board = board.create_board
      @h.board_to_game_state_string(game_board).length.should == 64
      @h.board_to_game_state_string(game_board).should == "r_r_r_r__r_r_r_rr_r_r_r__________________b_b_b_bb_b_b_b__b_b_b_b"
    end
  end

  describe "game_state_string_to_board" do
    it "translates game state strings into board objects" do
      game_state = "r_____r__r___r_rr_r___r__________________b_b______b_b____b_b___b"
      game_board = @h.game_state_string_to_board(game_state)
      game_board[1][7].color.should == :red
      game_board[5][3].color.should == :black
    end
  end

  describe "create_checker" do
    it "creates a checker based on string character input" do
      checker = @h.create_checker('r', 3, 3)
      checker.class.should == Checker
      checker.color.should == :red
    end
  end

  describe "move_checker" do
    it "moves a checker" do
      from = 'C3'
      to = 'D4'
      board = "r_r_r_r__r_r_r_rr_r_r_r__________________b_b_b_bb_b_b_b__b_b_b_b"
      @h.move_checker(from, to, board).should == nil
    end
  end

  describe "translate_move_squares_into_move" do
    it "converts from and to move squares into a move" do
      from = 'C3'
      to = 'D4'
      @h.translate_move_squares_into_move(from, to).should == [2, 2, 3, 3]
    end
  end

  describe "board_square_to_coordinate_pair" do
    it "converts a board square into a corresponding coordinate pair" do
      square = 'C3'
      @h.board_square_to_coordinate_pair(square).should == [2, 2]
    end
  end

  describe "no checkers left" do
    it "should tell when no checkers are left" do
      board = Board.new
      empty_board = board.create_test_board
      board.add_checker(empty_board, :red, 3, 3)
      @h.no_checkers_left(empty_board).should == true
    end
  end

end
