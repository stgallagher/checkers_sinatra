class Board

  def create_board
    board = Array.new(8)
    8.times { |index| board[index] = Array.new(8) }
    populate_checkers(board)
    #p "IN BOARD::CREATE BOARD -> board = #{board.inspect}"
    board
  end

  def create_test_board
    board = Array.new(8)
    8.times { |index| board[index] = Array.new(8) }
    board
  end

  def add_checker(board, color, x, y)
    board[x][y] = Checker.new(x, y, color)
  end

  def place_checker_on_board(board, checker)
    board[checker.x_pos][checker.y_pos] = checker
  end

  def populate_checkers(board)
    0.upto(2) do |x_coord|
      populate_checker(board, x_coord, :red)
    end

    5.upto(7) do |x_coord|
      populate_checker(board, x_coord, :black)
    end
    board
  end

  def populate_checker(board, x_coord, color)
    evens = [0, 2, 4, 6]
    odds  = [1, 3, 5, 7]

    apply_checker = lambda do |y_coord|
      checker = Checker.new(x_coord, y_coord, color)
      board[x_coord][y_coord] = checker
    end

    if x_coord.even?
      evens.each(&apply_checker)
    elsif x_coord.odd?
      odds.each(&apply_checker)
    end
  end

  def checkers_left(board, color)
    checker_count = 0

    board.each do |row|
      row.each do |location|
        if (location.nil? == false) and (location.color == color)
          checker_count += 1
        end
      end
    end
    checker_count
  end

  def self.king_checkers_if_necessary(board)
    board.each do |row|
      row.each do |loc|
        if (loc != nil) and (loc.color == :red) and (loc.x_pos == 7)
          loc.make_king
        elsif (loc != nil) and (loc.color == :black) and (loc.x_pos == 0)
          loc.make_king
        end
      end
    end
  end

  def self.remove_jumped_checker(board, x_origin, y_origin, x_destination, y_destination)
    x_delta = (x_destination > x_origin) ? 1 : -1
    y_delta = (y_destination > y_origin) ? 1 : -1

    board[x_origin + x_delta][y_origin + y_delta] = nil
    board
  end

  def self.return_jumped_checker(board, x_origin, y_origin, x_destination, y_destination)
    jumping_checker_color = board[x_destination][y_destination].color
    returning_checker_color = jumping_checker_color == :red ? :black : :red

    x_delta = (x_destination > x_origin) ? 1 : -1
    y_delta = (y_destination > y_origin) ? 1 : -1

    board[x_origin + x_delta][y_origin + y_delta] = Checker.new(x_origin + x_delta, y_origin + y_delta, returning_checker_color)
    board
  end

  def remove_checker(board, x, y)
    board[x][y] = nil
  end
end
