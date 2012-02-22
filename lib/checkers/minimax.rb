class Minimax

    INFINITY = 100000

    # Best move -> Have a method that generates all the possible moves, then apply the minimax to each one of those board positions, match the highest score
    #              and return the best move.
    #
    def initialize(board_survey, evaluation)
      @bs = board_survey
      @eval = evaluation
      @jumped_checker = []
      @multi_move = []
    end

    def best_move_negamax(board, player, depth, eval_choice)
      moves_list = @bs.generate_computer_moves(board, player)
      max = -INFINITY
      best_move = []
      moves_list.each do |move|
        process_move(board, move)
        score = -negamax(board, Game.switch_player(player), depth - 1, eval_choice)
        if score >= max
          max = score
          best_move = move
        end
        unprocess_move(board, move)
      end
      return best_move
    end

    def negamax(board, player, depth, eval_choice)
      #game over evaluation
      if game_over?(board)
        return_score = -INFINITY
        return return_score
      end

      #leaf evaluation
      if depth == 0
        evaluated_score = @eval.evaluation_chooser(eval_choice, board)
        return_score = player == :red ? evaluated_score : -evaluated_score
        return return_score
      end

      max = -INFINITY
      moves_list = @bs.generate_computer_moves(board, player)

      #no possible move evaluation
      if moves_list == []
        return_score = player == :red ? -INFINITY : INFINITY
        return return_score
      end

      #scoring each move
      moves_list.each do |move|
        process_move(board, move)
        score = -negamax(board, Game.switch_player(player), depth-1, eval_choice)
        if score > max
          max = score
        end
        unprocess_move(board, move)
      end

      #returning max
      return max
    end


    def game_over?(board)
      red_checkers = 0
      black_checkers = 0

      board.each do |row|
        row.each do |position|
          if position.nil? == false
            position.color == :red ? red_checkers += 1 : black_checkers += 1
          end
        end
      end
      red_checkers == 0 or black_checkers == 0
    end

    def process_move(board, move)
      if move[0].instance_of?(Array)
        @multi_move.push(move)
        move.each do |single_move|
          board = apply_move(board, single_move)
        end
      else
        board = apply_move(board, move)
      end
      board
    end

    def apply_move(board, move)
      checker = board[move[0]][move[1]]
      board[move[2]][move[3]] = checker
      board[move[0]][move[1]] = nil
      checker.x_pos = move[2]
      checker.y_pos = move[3]
      if (move[2] - move[0]).abs == 2
        x_delta = (move[2] > move[0]) ? 1 : -1
        y_delta = (move[3] > move[1]) ? 1 : -1
        @jumped_checker.push(board[move[0] + x_delta][move[1] + y_delta])
        board[move[0] + x_delta][move[1] + y_delta] = nil
      end
      board
    end

    def unapply_move(board, move)
      if (move[2] - move[0]).abs == 2
        Board.return_jumped_checker(board, move[0], move[1], move[2], move[3])
        x_delta = (move[2] > move[0]) ? 1 : -1
        y_delta = (move[3] > move[1]) ? 1 : -1

        board[move[0] + x_delta][move[1] + y_delta] = @jumped_checker.pop
        board
      end
      checker = board[move[2]][move[3]]
      board[move[0]][move[1]] = checker
      board[move[2]][move[3]] = nil
      checker.x_pos = move[0]
      checker.y_pos = move[1]
      board
    end

    def unprocess_move(board, move)
      if move[0].instance_of?(Array)
        multi_move = @multi_move.pop.reverse
        multi_move.each do |single_move|
          unapply_move(board, single_move)
        end
      else
        board = unapply_move(board, move)
      end
      board
    end

    def other_player(player)
      player == :red ? :black : :red
    end
end
