require_relative 'lib/checkers/board'
require_relative 'lib/checkers/checker'
require_relative 'lib/checkers/board_survey'
require_relative 'lib/checkers/evaluation'
require_relative 'lib/checkers/game'
require_relative 'lib/checkers/minimax'
require_relative 'lib/checkers/move_check'
require_relative 'lib/checkers/user_input'


COLUMN_LETTERS = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H']

class Helper

  def initialize
    @game = Game.new(nil)
    @mc = MoveCheck.new
  end

  def board_to_game_state_string(board)
      output_string = ""
      (0..7).each do |row|
        (0..7).each do |col|
          if board[row][col].nil?
            output_string << '_'
          elsif board[row][col].color == :red
            output_string << 'r'
          else
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
      else
        return Checker.new( x, y, :black)
      end
    end

    def move_checker(from, to, board)
      move = translate_move_squares_into_move(from, to)
      game_board = game_state_string_to_board(board)
      #p "IN MOVE_CHECKER => Before move validator game_board -> #{game_board}"
      message = @mc.move_validator(@game, game_board, :red, move[0], move[1], move[2], move[3])
      #p "IN MOVE_CHECKER => After move validator game_board -> #{game_board}"
      #p "IN MOVE_CHECKER => After move validator @game.game_board -> #{@game.game_board}"
      @board = game_board
      message
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

end
