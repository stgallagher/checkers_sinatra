require 'rubygems'
require 'sinatra'
require_relative 'lib/checkers/board'
require_relative 'lib/checkers/checker'
require_relative 'lib/checkers/board_survey'
require_relative 'lib/checkers/evaluation'
require_relative 'lib/checkers/game'
require_relative 'lib/checkers/minimax'
require_relative 'lib/checkers/move_check'
require_relative 'lib/checkers/user_input'

  before do
    @game = Game.new(nil)
    @player = @game.current_player
    @board = @game.game_board
    @move_validate = @game.move_check
  end

  enable :sessions

  get '/' do
    erb :index
  end

  get '/gameplay' do
    erb :gameplay
  end

  get '/gameplay/:location' do
    session[:location] << params[:location]
    redirect '/read'
  end

  get '/read' do
    p "location in session has a value of #{session[:location]}"
    erb :gameplay
  end

  get '/test' do
    erb :test
  end

  helpers do

    def move_getter(move)
      if @from == nil
        @from = move
      else
        @to = move
        complete_move = coordinate_translator(@from, @to)
        @move_validate.move_validator(@game, @board, @current_player, complete_move[0], complete_move[1], complete_move[2], complete_move[3])
        @from = nil
        @to = nil
      end
    end

    def coordinate_translator(from, to)
      first  = board_square_to_coordinate_pair(from)
      second = board_square_to_coordinate_pair(to)
      first + second
    end

  end

