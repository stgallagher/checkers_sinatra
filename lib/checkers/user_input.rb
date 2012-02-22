class UserInput
  
  def translate_move_request_to_coordinates(move_request)
    coords_array = move_request.chomp.split(',').map { |x| x.to_i }
  end
end
