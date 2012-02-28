    def revised_game_test
      message = nil
      if (@number_of_players == 'one' or @number_of_players == 'none') and @current_player == :red
        @move =@minmax.best_move_negamax(@game_board, :red, 4, @difficulty)
        if @move.nil?
          @view.game_is_over(:red)
        end
        if @move[0].instance_of?(Array)
          @move.each do |single_move|
            message = @move_check.move_validator(self, @game_board, :red,  single_move[0], single_move[1], single_move[2], single_move[3])
            sleep(1)
          end
        else
          message = @move_check.move_validator(self, @game_board, :red,  @move[0], @move[1], @move[2], @move[3])
        end
      elsif @number_of_players == 'none' and @current_player == :black
        @move =@minmax.best_move(@game_board, :black, 4, @difficulty)
        if @move.nil?
          @view.game_is_over(:black)
        end
        message = @move_check.move_validator(self, @game_board, :black,  @move[0], @move[1], @move[2], @move[3])
      else
        @move = nil
        while @move.nil?
          sleep(0.1)
        end
        message = @move_check.move_validator(self, @game_board, @current_player, @move[0], @move[1], @move[2], @move[3])
      end
      @view.move_feedback(message, @move)
    end
