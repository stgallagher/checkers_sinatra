class MoveCheck

  attr_accessor :board, :current_player

  def initialize
    @survey = BoardSurvey.new
    @consecutive_jumps = false
  end

  def move_validator(game, board, current_player, x_origin, y_origin, x_destination, y_destination)
    message = nil

    game.current_player = current_player

    case
    when (@consecutive_jumps and board[x_origin][y_origin] != @consecutive_jumper)
      message =  "You cannot jump with a different checker"

    when trying_to_move_to_a_void_square(x_destination, y_destination)
      message = "You cannot move to a void square"

    when out_of_bounds?(x_destination, y_destination)
      message = "You cannot move off the board"

    when no_checker_at_origin?(board, x_origin, y_origin)
      message = "There is no checker to move in requested location"

    when trying_to_move_opponents_checker?(board,current_player, x_origin, y_origin)
      message = "You cannot move an opponents checker"

    when attempted_non_diagonal_move?(x_origin, y_origin, x_destination, y_destination)
      message = "You can only move a checker diagonally"

    when trying_to_move_more_than_one_space_and_not_jumping?(x_origin, y_origin, x_destination, y_destination)
      message = "You cannot move more than one space if not jumping"

    when attempted_move_to_occupied_square?(board, x_destination, y_destination)
      message = "You cannot move to an occupied square"

    when non_king_moving_backwards?(board, current_player, x_origin, y_origin, x_destination)
      message = "A non-king checker cannot move backwards"

    when attempted_jump_of_empty_space?(board,current_player, x_origin, y_origin, x_destination, y_destination)
      message = "You cannot jump an empty space"

    when attempted_jump_of_own_checker?(board, current_player, x_origin, y_origin, x_destination, y_destination)
      message = "You cannot jump a checker of your own color"

    when jump_available_and_not_taken?(board, current_player, x_destination, y_destination)
      message = "You must jump if a jump is available"

    else
      Game.move(board, x_origin, y_origin, x_destination, y_destination)

      if jumping_move?(x_origin, x_destination)
        message = "jumping move"
        Board.remove_jumped_checker(board, x_origin, y_origin, x_destination, y_destination)
        @consecutive_jumps = false

        if @survey.any_jumps_left?(board, current_player, x_destination, y_destination)
          @consecutive_jumps = true
          @consecutive_jumper = board[x_destination][y_destination]
        end
      end
      Board.king_checkers_if_necessary(board)
    end

    if message == nil or (message == "jumping move" and @survey.any_jumps_left?(board, current_player, x_destination, y_destination)== false)
       if @consecutive_jumps == false
        game.current_player = Game.switch_player(current_player)
       end
    end
    message
  end

  def jump_available?(board, current_player)
    possible_jumps = @survey.generate_jump_locations_list(board, current_player)

    possible_jumps.size > 0
  end

  def jump_available_and_not_taken?(board, current_player, x_destination, y_destination)
    jump_possiblities = @survey.generate_jump_locations_list(board, current_player)

    not_taken_jump = true
    jump_possiblities.each_slice(2) do |i|
      if(i[0] == x_destination) and (i[1] == y_destination)
        not_taken_jump = false
      end
    end
    (jump_available?(board, current_player) == true) and (not_taken_jump)
  end

  def jump_deltas(current_player, x_orig, y_orig, x_dest, y_dest)
    deltas = []
    x_dest > x_orig ? deltas << 1 : deltas << -1
    y_dest > y_orig ? deltas << 1 : deltas << -1
  end

  def trying_to_move_to_a_void_square(x_destination, y_destination)
    (0..7).each do |row|
      (0..7).each do |col|
        if row % 2 == 0 and col % 2 == 1
          return true if x_destination == row and y_destination == col
        elsif row % 2 == 1 and col % 2 == 0
          return true if x_destination == row and y_destination == col
        end
      end
    end
    return false
  end

  def attempted_jump_of_empty_space?(board, current_player, x_origin, y_origin, x_destination, y_destination)
    if jumping_move?(x_origin, x_destination)
      deltas = jump_deltas(current_player, x_origin, y_origin, x_destination, y_destination)
      board[x_origin + deltas[0]][y_origin + deltas[1]].nil?  ? true  : false
    else
      false
    end
  end

  def attempted_jump_of_own_checker?(board, current_player, x_origin, y_origin, x_destination, y_destination)
    if jumping_move?(x_origin, x_destination)
      x_delta = (x_destination > x_origin) ? 1 : -1
      y_delta = (y_destination > y_origin) ? 1 : -1

      if current_player == :black
       x_delta = (x_destination < x_origin) ? -1 : 1
       y_delta = (y_destination < y_origin) ? -1 : 1
     end

      jumped_checker_x_value = x_origin + x_delta
      jumped_checker_y_value = y_origin + y_delta

      jumped_checker = board[jumped_checker_x_value][jumped_checker_y_value]

      jumping_checker = board[x_origin][y_origin]

      jumped_checker.color == jumping_checker.color
    end
  end

  def jumping_move?(x_origin, x_destination)
    (x_destination - x_origin).abs == 2
  end

  def out_of_bounds?(x, y)
   ( x < 0  or y < 0) or (x > 7  or y > 7)
  end

  def no_checker_at_origin?(board, x_origin, y_origin)
    board[x_origin][y_origin].nil?
  end

  def trying_to_move_opponents_checker?(board, current_player, x_origin, y_origin)
    current_player != board[x_origin][y_origin].color
  end

  def trying_to_move_more_than_one_space_and_not_jumping?(x_origin, y_origin, x_destination, y_destination)
    (x_destination - x_origin).abs > 2 or (y_destination - y_origin).abs > 2
  end

  def attempted_non_diagonal_move?(x_origin, y_origin, x_destination, y_destination)
    (x_origin == x_destination) or (y_origin == y_destination) or (x_destination - x_origin).abs != (y_destination - y_origin).abs
  end

  def attempted_move_to_occupied_square?(board, x_destination, y_destination)
    not board[x_destination][y_destination].nil?
  end

  def non_king_moving_backwards?(board, current_player, x_origin, y_origin, x_destination)
    if current_player == :red
      (x_destination < x_origin) and (board[x_origin][y_origin].is_king? == false)
    else
      (x_destination > x_origin) and (board[x_origin][y_origin].is_king? == false)
    end
  end
end
