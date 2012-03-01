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

  COLUMN_LETTERS = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H']

  before do
    @game = Game.new(nil)
    @mc = @game.move_check
    @number_of_players =  session[:players]
    @difficulty = difficulty_converter(session[:difficulty])
      p "IN BEFOREALL :: @difficulty = #{@difficulty}, session[:difficulty] = #{session[:difficulty].inspect}"
    bs = BoardSurvey.new
    evaluator = Evaluation.new
    @minmax = Minimax.new(bs, evaluator)
  end

  before'/gameplay'  do
    @board = @game.board.create_board
    session[:player] = :red
    @difficulty = difficulty_converter(params[:difficulty])
    @player = :red
    if @number_of_players == :one
      p "IN BEFOREGAMEPLAY :: @difficulty = #{@difficulty}, @player = #{@player}, @board = #{@board}"
      computer_player_move(@difficulty, @player, @board)
    end
  end

  enable :sessions

  get '/' do
    erb :index
  end

  get '/gameplay' do
    erb :gameplay
  end

  post '/gameplay' do
    @number_of_players = params[:players].to_sym
    session[:players] = @number_of_players
    session[:difficulty] = params[:difficulty]
    @difficulty = difficulty_converter(params[:difficulty])
    erb :gameplay
  end

  get '/computersturn/:game_state' do |game_state|
      p "IN COMPUTERSTURN :: @difficulty = #{@difficulty}, @player = #{@player}, @board = #{@board}"
    computer_player_move(@difficulty, params[:player].to_sym, params[:board])
    if @game_over
      erb :gameover
    else
      erb :gameplay
    end
  end

  get '/gameplay/:game_state' do |game_state|
    @from = params[:game_state]

    if params[:from] != ""
      human_player_move(params[:from], params[:game_state], params[:player], params[:board])
      if @number_of_players == :one and @player == :red
        @computers_turn = true
      end
    else
      @board = game_state_string_to_board(params[:board])
      session[:player] = params[:player] if params[:player].nil? == false
      @player = session[:player]
    end

    if @winner
      erb :gameover
    else
      erb :gameplay
    end
  end

  get '/loadgame' do
    erb :test
  end

  helpers do

    def computer_player_move(difficulty, player, board)
      board = game_state_string_to_board(board) if board.class == String
      move = @minmax.best_move_negamax(board, player, 4, difficulty)
      if move.nil?
        @winner = :black
      end
      if move[0].instance_of?(Array)
        move.each do |single_move|
          message = @mc.move_validator(@game, board, :red,  single_move[0], single_move[1], single_move[2], single_move[3])
        end
      else
        @message = @mc.move_validator(@game, board, :red,  move[0], move[1], move[2], move[3])
      end
      session[:player] = @game.current_player if @game.current_player.nil? == false
      @board = board
      @player = session[:player]
    end

    def human_player_move(from, to, player, board)
      move_checker(from, to, player, board)
    end

    def move_checker(from, to, player, board)
      move = translate_move_squares_into_move(from, to)
      if move.nil?
        @winner = player == :red ? :black : :red
      end
      game_board = game_state_string_to_board(board)

      @message = @mc.move_validator(@game, game_board, player.to_sym, move[0], move[1], move[2], move[3])

      @from = nil
      @board = game_board

      session[:player] = @game.current_player if @game.current_player.nil? == false
      @player = session[:player]
    end

    def board_to_game_state_string(board)
      output_string = ""
      (0..7).each do |row|
        (0..7).each do |col|
          if board[row][col].nil?
            output_string << '_'
          elsif board[row][col].color == :red and board[row][col].is_king?
            output_string << 's'
          elsif board[row][col].color == :red
            output_string << 'r'
          elsif board[row][col].color == :black and board[row][col].is_king?
            output_string << 'c'
          elsif board[row][col].color == :black
            output_string << 'b'
          end
        end
      end
      output_string
    end

    def game_state_string_to_board(game_state)
      board = Board.new
      game_board = board.create_test_board

      game_state_array = []
      game_state.each_char { |char| game_state_array << char}
      row_index = 0
      game_state_array.each_slice(8) do |row|
        row.each_with_index do |square, col_index|
          unless square == '_'
            game_board[row_index][col_index] = create_checker(square, row_index, col_index)
          end
        end
        row_index += 1
      end
      game_board
    end

    def create_checker(checker, x, y)
      if checker == 'r'
        return Checker.new( x, y, :red)
      elsif checker == 's'
        created_checker = Checker.new( x, y, :red)
        created_checker.make_king
        return created_checker
      elsif checker == 'b'
        return Checker.new( x, y, :black)
      elsif checker == 'c'
        created_checker = Checker.new( x, y, :black)
        created_checker.make_king
        return created_checker
      end
    end

    def translate_move_squares_into_move(from, to)
      first  = board_square_to_coordinate_pair(from)
      second = board_square_to_coordinate_pair(to)
      first + second
    end

    def board_square_to_coordinate_pair(board_square)
      coords = []
      board_square.each_char do |char|
        if COLUMN_LETTERS.include?(char)
          coords << COLUMN_LETTERS.index(char)
        else
        coords << char.to_i - 1
        end
      end
      coords.reverse
    end

    def difficulty_converter(difficulty)
      if difficulty == 'Easy'
        difficulty = 1
      elsif difficulty == 'Board Scoring'
        difficulty = 3
      elsif difficulty == 'Checker Counting'
        difficulty = 2
      end
      difficulty
    end

  end

