class_name MovementRules

extends RefCounted


static var _first_white_piece_moved := false
static var _first_black_piece_moved := false


static func is_pawn_movement_correct(movement_delta: Vector2i, selected_piece) -> bool:
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
