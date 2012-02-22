class Evaluation

  def initialize
    @mc = MoveCheck.new
  end

  BOARD_WEIGHT = [ [   4, nil,   4, nil,   4, nil,   4, nil],
                   [ nil,   3, nil,   3, nil,   3, nil,   4],
                   [   4, nil,   2, nil,   2, nil,   3, nil],
                   [ nil,   3, nil,   1, nil,   2, nil,   4],
                   [   4, nil,   2, nil,   1, nil,   3, nil],
                   [ nil,   3, nil,   2, nil,   2, nil,   4],
                   [   4, nil,   3, nil,   3, nil,   3, nil],
                   [ nil,   4, nil,   4, nil,   4, nil,   4], ]

  def evaluation_chooser(choice, board)
    if choice == 1
      evaluate_board1(board)
    elsif choice == 2
      evaluate_board2(board)
    elsif choice == 3
      evaluate_board3(board)
    end
  end

  def evaluate_board1(board)
    player_value = 0
    opponent_value = 0

    #color == :red ? opponent_color = :black : opponent_color = :red

    board.each do |row|
      row.each do |position|
        if position.nil? == false
          position.color == :red  ? player_value += calculate_value(position, :red) : opponent_value += calculate_value(position, :black)
        end
      end
    end
    if @mc.jump_available?(board, :black)
      opponent_value += 50
    end

    return player_value - opponent_value
  end

  def evaluate_board2(board)
    red_count= 0
    black_count = 0

    board.each do |row|
      row.each do |position|
        if position.nil? == false
          position.color == :red  ? red_count += 1 : black_count += 1
        end
      end
    end
    return red_count - black_count
  end

  def evaluate_board3(board)
    return 0
  end

  def calculate_value(position, color)
    if color == :red
      if position.x_pos == 7
        value = 10
      elsif position.x_pos == 5 or position.x_pos == 6
        value = 7
      else
        value = 5
      end
    elsif color == :black
      if position.x_pos == 0
        value = 10
      elsif position.x_pos == 1 or position.x_pos == 2
        value = 7
      else
        value = 5
      end
    end

    if position.is_king?
      value = 10
    end
    return value * BOARD_WEIGHT[position.x_pos][position.y_pos]
  end
end
