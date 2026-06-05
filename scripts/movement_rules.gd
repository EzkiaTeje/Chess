class_name MovementRules
extends RefCounted


static var _first_white_piece_moved := false
static var _first_black_piece_moved := false


static func is_pawn_movement_correct(movement_delta: Vector2i, board_clicked_position: Vector2i, selected_piece: Piece, pieces: Array) -> bool:
	# -------------------------------
	# Pawn diagonal and eat movement.
	if selected_piece.piece_color == Globals.PIECE_COLORS.WHITE:
			if movement_delta == Vector2i(-1, -1) or movement_delta == Vector2i(1, -1):
				if _is_square_occupied_by_rival(board_clicked_position, selected_piece, pieces):
					return true
	if selected_piece.piece_color == Globals.PIECE_COLORS.BLACK:
			if movement_delta == Vector2i(-1, 1) or movement_delta == Vector2i(1, 1):
				if _is_square_occupied_by_rival(board_clicked_position, selected_piece, pieces):
					return true
	# -------------------------------
	if selected_piece.piece_color == Globals.PIECE_COLORS.WHITE:
		if _first_white_piece_moved:
			if movement_delta == Vector2i(0, -1):
				return true
		else:
			if movement_delta == Vector2i(0, -1) or movement_delta == Vector2i(0, -2):
				_first_white_piece_moved = true
				return true
	if selected_piece.piece_color == Globals.PIECE_COLORS.BLACK:
		if _first_black_piece_moved:
			if movement_delta == Vector2i(0, 1):
				return true
		else:
			if movement_delta == Vector2i(0, 1) or movement_delta == Vector2i(0, 2):
				_first_black_piece_moved = true
				return true
	return false


static func _is_square_occupied_by_rival(board_clicked_position: Vector2i, selected_piece: Piece, pieces: Array) -> bool:
	for piece in pieces:
		if piece == selected_piece:
			continue
		if Vector2i(piece.position / Globals.CELL_SIZE) == board_clicked_position and piece.piece_color != selected_piece.piece_color:
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


static func is_pawn_movement_occupied(start_position: Vector2i, selected_piece: Piece, pieces: Array) -> bool:
	if selected_piece.piece_color == Globals.PIECE_COLORS.WHITE:
		return _is_square_occupied(Vector2i(start_position.x, start_position.y - 1), selected_piece, pieces)
	else:
		return _is_square_occupied(Vector2i(start_position.x, start_position.y + 1), selected_piece, pieces)


static func is_rook_bishop_queen_movement_occupied(board_clicked_position: Vector2i, start_position: Vector2i, movement_delta: Vector2i, selected_piece: Piece, pieces: Array) -> bool:
	var step := Vector2i(sign(movement_delta.x), sign(movement_delta.y))
	var current := start_position + step
	while current != board_clicked_position:
		if _is_square_occupied(current, selected_piece, pieces):
			return true
		current += step
	return false


static func _is_square_occupied(board_position: Vector2i, selected_piece: Piece, pieces: Array) -> bool:
	for piece in pieces:
		if piece == selected_piece:
			continue
		if Vector2i(piece.position / Globals.CELL_SIZE) == board_position:
			return true
	return false
