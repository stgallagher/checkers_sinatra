class Game

  attr_accessor :difficulty, :number_of_players, :move_check, :game_board, :board, :gui, :single_player_game, :current_player , :x_orig, :y_orig, :x_dest, :y_dest

  def initialize(view)
    @view = view
    @current_player = :red
    @bs = BoardSurvey.new
    @evaluation = Evaluation.new
    @input = UserInput.new
    @move_check = MoveCheck.new
    @board = Board.new
    @game_board = @board.create_board
    @minmax = Minimax.new(@bs, @evaluation)
    @number_of_players = 'two'
    @difficulty = 0
  end

  def play_test_game
    @game_board = @board.create_test_board
    @board.add_checker(@game_board, :red, 0, 0)
    @board.add_checker(@game_board, :red, 0, 2)
    @board.add_checker(@game_board, :black, 7, 5)
    @board.add_checker(@game_board, :black, 7, 7)
    play_game
  end

  def play_game
    options = @view.begin_game
    @difficulty = options[0]
    @number_of_players = options[1]
    while(game_over?(@game_board) == false)
      message = nil
      @view.render_board(@game_board)
      if @number_of_players == 'one' and @current_player == :red
        move =@minmax.best_move(@game_board, :red, 3, @difficulty)
        message = @move_check.move_validator(self, @game_board, :red,  move[0], move[1], move[2], move[3])
      else
        move = @view.get_move_coordinates(@current_player)
        message = @move_check.move_validator(self, @game_board, @current_player, move[0], move[1], move[2], move[3])
      end

      @view.move_feedback(message, move)
    end
    @view.render_board(@game_board)
    winner = determine_winner(@game_board)
    @view.game_over(winner)
  end

  def determine_winner(board)
    winner = @board.checkers_left(board, :black) == 0 ? :red : :black
  end

  def self.move(board, x_origin, y_origin, x_destination, y_destination)
    #moving
    moving_checker = board[x_origin][y_origin]

    # set new location for checker
    moving_checker.x_pos = x_destination
    moving_checker.y_pos = y_destination

    # update board positions of checker
    board[x_origin][y_origin] = nil
    board[x_destination][y_destination] = moving_checker
  end

  def game_over?(board)
    @board.checkers_left(board, :black) == 0 or @board.checkers_left(board, :red) == 0
  end

  def self.switch_player(current_player)
    current_player == :red ? :black : :red
  end

  def save_game(name, game_board, current_player, difficulty, number_of_players)
    game_info = { :board => game_board,
                  :current_player => current_player,
                  :difficulty => difficulty,
                  :number_of_players => number_of_players}

    saved_game = Marshal.dump(game_info)
    file = File.new(name, 'w')
    file.write saved_game
    file.close
  end

  def save(filename)
    save_game(filename, @game_board, @current_player, @difficulty, @number_of_players)
    return " - Save Successful - "
  end

  def load(filename)
    file = File.open(filename, 'r')
    loaded_game = Marshal.load file.read
    file.close

    @current_player = loaded_game[:current_player]
    @game_board = loaded_game[:board]
    @difficulty = loaded_game[:difficulty]
    @number_of_players = loaded_game[:number_of_players]

    return " - Load Successful - "
  end

end
