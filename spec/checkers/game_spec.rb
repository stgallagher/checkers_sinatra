require 'spec_helper'
require 'fileutils'

describe Game do
  before(:each) do
    view = Gui.new
    @game = Game.new(view)
    @board = Board.new
    @new_game_board = @board.create_board
    @clear_board = @board.create_test_board
  end

  it "should move a checker" do
    @board.add_checker(@new_game_board, :red, 3, 3)
    moving_checker = @new_game_board[3][3]
    Game.move(@new_game_board, 3, 3, 4, 4)
    @new_game_board[4][4].should equal(moving_checker)
  end

  it "should tell when the game is over (no checkers left for either player)" do
    @board.add_checker(@clear_board, :red, 3, 3)
    @board.add_checker(@clear_board, :black, 5, 5)
    @game.game_over?(@clear_board).should == false
    @board.remove_checker(@clear_board, 3, 3)
    @game.game_over?(@clear_board).should == true
  end

  it "should switch player" do
    @game.current_player = :red
    Game.switch_player(@game.current_player).should == :black
  end

  it "saves the game" do
    @game.save_game('saved_games/test_file', @new_game_board, @game.current_player, @game.difficulty, @game.number_of_players)
    File.exists?(File.expand_path("saved_games/test_file")).should == true
  end

  it "loads a game" do
    @board.add_checker(@clear_board, :red, 3, 3)
    @board.add_checker(@clear_board, :black, 4, 4)
    @game.current_player = :black
    @game.difficulty = 1
    @game.number_of_players = 'one'
    @game.save_game('saved_games/test_file', @clear_board, @game.current_player, @game.difficulty, @game.number_of_players)
    @game.load('saved_games/test_file')
    @game.game_board[3][3].color == :red
    @game.game_board[4][4].color == :black
    @game.game_board[0][0].should == nil
    @game.current_player.should == :black
    @game.difficulty.should == 1
    @game.number_of_players.should == 'one'
  end

end
