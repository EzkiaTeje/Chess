class_name MovementRules
extends RefCounted


static func is_pawn_movement_correct(movement_delta: Vector2i, board_clicked_position: Vector2i, selected_piece: Piece, pieces: Array[Piece]) -> bool:
	if selected_piece.piece_color == Globals.PIECE_COLORS.WHITE:
		if movement_delta == Vector2i(-1, -1) or movement_delta == Vector2i(1, -1):
			if is_square_occupied_by_rival(board_clicked_position, selected_piece, pieces):
				return true
	if selected_piece.piece_color == Globals.PIECE_COLORS.BLACK:
		if movement_delta == Vector2i(-1, 1) or movement_delta == Vector2i(1, 1):
			if is_square_occupied_by_rival(board_clicked_position, selected_piece, pieces):
				return true

	if selected_piece.piece_color == Globals.PIECE_COLORS.WHITE:
		if selected_piece.position.y / Globals.CELL_SIZE == 6:
			if movement_delta == Vector2i(0, -1) or movement_delta == Vector2i(0, -2):
				return true
		else:
			if movement_delta == Vector2i(0, -1):
				return true
	if selected_piece.piece_color == Globals.PIECE_COLORS.BLACK:
		if selected_piece.position.y / Globals.CELL_SIZE == 1:
			if movement_delta == Vector2i(0, 1) or movement_delta == Vector2i(0, 2):
				return true
		else:
			if movement_delta == Vector2i(0, 1):
				return true

	return false


static func is_rook_movement_correct(movement_delta: Vector2i) -> bool:
	if movement_delta.x == 0 or movement_delta.y == 0:
		return true
	return false


static func is_knight_movement_correct(movement_delta: Vector2i) -> bool:
	if abs(movement_delta) == Vector2i(1,2) or abs(movement_delta) == Vector2i(2,1):
		return true
	return false


static func is_bishop_movement_correct(movement_delta: Vector2i) -> bool:
	if abs(movement_delta.x) == abs(movement_delta.y):
		return true
	return false


static func is_king_movement_correct(movement_delta: Vector2i) -> bool:
	if abs(movement_delta) == Vector2i(0, 1) or abs(movement_delta) == Vector2i(1, 1) or abs(movement_delta) == Vector2i(1, 0):
		return true
	return false


static func is_queen_movement_correct(movement_delta: Vector2i) -> bool:
	if abs(movement_delta.x) == abs(movement_delta.y) or movement_delta.x == 0 or movement_delta.y == 0:
		return true
	return false


static func is_pawn_movement_occupied(start_position: Vector2i, selected_piece: Piece, pieces: Array[Piece]) -> bool:
	if selected_piece.piece_color == Globals.PIECE_COLORS.WHITE:
		return is_square_occupied(Vector2i(start_position.x, start_position.y - 1), selected_piece, pieces)
	else:
		return is_square_occupied(Vector2i(start_position.x, start_position.y + 1), selected_piece, pieces)


static func is_rook_bishop_queen_movement_occupied(board_clicked_position: Vector2i, start_position: Vector2i, movement_delta: Vector2i, selected_piece: Piece, pieces: Array[Piece]) -> bool:
	var step := Vector2i(sign(movement_delta.x), sign(movement_delta.y))
	var current := start_position + step
	while current != board_clicked_position:
		if is_square_occupied(current, selected_piece, pieces):
			return true
		current += step
	return false


static func is_square_occupied(board_position: Vector2i, selected_piece: Piece, pieces: Array[Piece]) -> bool:
	for piece in pieces:
		if piece == selected_piece:
			continue
		if Vector2i(piece.position / Globals.CELL_SIZE) == board_position:
			return true
	return false


static func is_square_occupied_by_rival(board_position: Vector2i, selected_piece: Piece, pieces: Array[Piece]) -> bool:
	for piece in pieces:
		if piece == selected_piece:
			continue
		if Vector2i(piece.position / Globals.CELL_SIZE) == board_position and piece.piece_color != selected_piece.piece_color:
			return true
	return false


static func is_square_occupied_by_ally(board_position: Vector2i, selected_piece: Piece, pieces: Array[Piece]) -> bool:
	for piece in pieces:
		if piece == selected_piece:
			continue
		if Vector2i(piece.position / Globals.CELL_SIZE) == board_position and piece.piece_color == selected_piece.piece_color:
			return true
	return false


static func check_pawn_to_queen(selected_piece: Piece) -> void:
	if selected_piece.piece_type == Globals.PIECE_TYPES.PAWN:
		if selected_piece.piece_color == Globals.PIECE_COLORS.WHITE and (selected_piece.position.y / Globals.CELL_SIZE) == 0:
			selected_piece.piece_type = Globals.PIECE_TYPES.QUEEN
			selected_piece.update_sprite()
		elif selected_piece.piece_color == Globals.PIECE_COLORS.BLACK and (selected_piece.position.y / Globals.CELL_SIZE) == 7:
			selected_piece.piece_type = Globals.PIECE_TYPES.QUEEN
			selected_piece.update_sprite()
