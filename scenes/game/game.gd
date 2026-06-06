extends Node2D


signal turn_changed(turn: int)
signal game_paused(paused: bool)
signal game_ended(winner: String)

var _piece_scene = preload("res://scenes/piece/piece.tscn")
var pieces: Array[Piece]
var selected_piece: Piece
var _paused := false
var _current_turn := Globals.PIECE_COLORS.WHITE
var _valid_moves: Array[Vector2i] = []


func _ready() -> void:
	_create_pieces()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if _paused:
			$CanvasLayer/PauseMenu.visible = false
			get_tree().paused = false
			_paused = !_paused
		else:
			$CanvasLayer/PauseMenu.visible = true
			get_tree().paused = true
			_paused = !_paused
		return
	
	if not (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		return
	if not selected_piece:
		return

	var board_clicked_position := _get_board_position()
	if board_clicked_position == Vector2i(-1, -1):
		_deselect()
		return
	if _is_own_square(board_clicked_position):
		return
	if not _is_correct_movement(board_clicked_position):
		return
	if _is_piece_blocked(board_clicked_position):
		return
	if _try_eating(board_clicked_position):
		return

	selected_piece.move_piece(board_clicked_position)
	MovementRules.check_pawn_to_queen(selected_piece)
	_deselect()
	_switch_turn()


func _get_board_position() -> Vector2i:
	var board_clicked_position := Vector2i((get_local_mouse_position() / Globals.CELL_SIZE).floor())
	if not Rect2i(0, 0, 8, 8).has_point(board_clicked_position):
		return Vector2i(-1, -1)
	return board_clicked_position


func _is_own_square(board_clicked_position: Vector2i) -> bool:
	return board_clicked_position == Vector2i(selected_piece.position / Globals.CELL_SIZE)


func _try_eating(board_clicked_position: Vector2i) -> bool:
	for piece in pieces:
		if piece == selected_piece:
			continue
		if Vector2i(piece.position / Globals.CELL_SIZE) != board_clicked_position:
			continue

		if piece.piece_color == selected_piece.piece_color:
			return true

		if piece.piece_type == Globals.PIECE_TYPES.KING:
			_end_game(piece.piece_color)
			piece.queue_free()
			pieces.erase(piece)
			selected_piece.move_piece(board_clicked_position)
			MovementRules.check_pawn_to_queen(selected_piece)
			_deselect()
			process_mode = Node.PROCESS_MODE_DISABLED
			return true

		piece.queue_free()
		pieces.erase(piece)
		return false

	return false


func _is_correct_movement(board_clicked_position: Vector2i) -> bool:
	var start_position := Vector2i(selected_piece.position / Globals.CELL_SIZE)
	var movement_delta := board_clicked_position - start_position

	match selected_piece.piece_type:
		Globals.PIECE_TYPES.PAWN:
			if MovementRules.is_pawn_movement_correct(movement_delta, board_clicked_position, selected_piece, pieces):
				return true
		Globals.PIECE_TYPES.ROOK:
			if MovementRules.is_rook_movement_correct(movement_delta):
				return true
		Globals.PIECE_TYPES.KNIGHT:
			if MovementRules.is_knight_movement_correct(movement_delta):
				return true
		Globals.PIECE_TYPES.BISHOP:
			if MovementRules.is_bishop_movement_correct(movement_delta):
				return true
		Globals.PIECE_TYPES.KING:
			if MovementRules.is_king_movement_correct(movement_delta):
				return true
		Globals.PIECE_TYPES.QUEEN:
			if MovementRules.is_queen_movement_correct(movement_delta):
				return true
	return false


func _is_piece_blocked(board_clicked_position: Vector2i) -> bool:
	var start_position := Vector2i(selected_piece.position / Globals.CELL_SIZE)
	var movement_delta := board_clicked_position - start_position

	match selected_piece.piece_type:
		Globals.PIECE_TYPES.PAWN:
			if movement_delta.y != 0 and movement_delta.x == 0:
				if MovementRules.is_pawn_movement_occupied(start_position, selected_piece, pieces):
					return true
		Globals.PIECE_TYPES.ROOK, Globals.PIECE_TYPES.BISHOP, Globals.PIECE_TYPES.QUEEN:
			if MovementRules.is_rook_bishop_queen_movement_occupied(board_clicked_position, start_position, movement_delta, selected_piece, pieces):
				return true
	return false


func _end_game(lost_color: int) -> void:
	var winner := "BLACK" if lost_color == Globals.PIECE_COLORS.WHITE else "WHITE"
	game_ended.emit(winner)
	print(winner + " WON")


func _deselect() -> void:
	if selected_piece:
		selected_piece.modulate = Color.WHITE
	selected_piece = null
	_valid_moves.clear()
	queue_redraw()


func _switch_turn() -> void:
	if _current_turn == Globals.PIECE_COLORS.BLACK:
		_current_turn = Globals.PIECE_COLORS.WHITE
		turn_changed.emit(_current_turn)
	else:
		_current_turn = Globals.PIECE_COLORS.BLACK
		turn_changed.emit(_current_turn)


func _create_pieces() -> void:
	for i in range(Globals.TOTAL_PIECES):
		var piece_instance = _piece_scene.instantiate()
		add_child(piece_instance)
		pieces.append(piece_instance)
		piece_instance.init_piece(Globals.STARTING_POSITIONS[i])
		piece_instance.get_node("Area2D").input_event.connect(_on_piece_clicked.bind(piece_instance))


func _on_piece_clicked(_viewport: Node, event: InputEvent, _shape_idx: int, piece: Piece) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if piece not in pieces:
			return

		if piece.piece_color != _current_turn:
			return
		
		if selected_piece == piece:
			_deselect()
			return

		if selected_piece:
			selected_piece.modulate = Color.WHITE

		selected_piece = piece
		selected_piece.modulate = Color.GREEN

		_valid_moves = _get_valid_moves_for(selected_piece)
		queue_redraw()    


func _draw() -> void:
	for pos in _valid_moves:
		draw_rect(Rect2(pos * Globals.CELL_SIZE, Vector2(Globals.CELL_SIZE, Globals.CELL_SIZE)), Color.GREEN, false, 2.0)


func _get_valid_moves_for(piece: Piece) -> Array[Vector2i]:
	var valid_moves: Array[Vector2i] = []
	var start_position = Vector2i(selected_piece.position / Globals.CELL_SIZE)
	var directions: Array[Vector2i]
	var sliding := false
	
	match piece.piece_type:
		Globals.PIECE_TYPES.PAWN:
			_add_pawn_moves(start_position, piece, valid_moves)
			return valid_moves
		Globals.PIECE_TYPES.ROOK:
			directions = [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]
			sliding = true
		Globals.PIECE_TYPES.KNIGHT:
			directions = [Vector2i(1,2), Vector2i(2,1), Vector2i(2,-1), Vector2i(1,-2), Vector2i(-1,-2), Vector2i(-2,-1), Vector2i(-2,1), Vector2i(-1,2)]
		Globals.PIECE_TYPES.BISHOP:
			directions = [Vector2i(1,1), Vector2i(1,-1), Vector2i(-1,1), Vector2i(-1,-1)]
			sliding = true
		Globals.PIECE_TYPES.KING:
			directions = [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1), Vector2i(1,1), Vector2i(1,-1), Vector2i(-1,1), Vector2i(-1,-1)]
		Globals.PIECE_TYPES.QUEEN:
			directions = [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1), Vector2i(1,1), Vector2i(1,-1), Vector2i(-1,1), Vector2i(-1,-1)]
			sliding = true

	# For non pawns
	for direction in directions:
		if sliding:
			var i := 1
			while true:
				var to = start_position + direction * i
				if not Rect2i(0, 0, 8, 8).has_point(to):
					break
				if MovementRules.is_square_occupied_by_ally(to, piece, pieces):
					break
				valid_moves.append(to)
				if MovementRules.is_square_occupied_by_rival(to, piece, pieces):
					break
				i += 1
		else:
			var to = start_position + direction
			if not Rect2i(0, 0, 8, 8).has_point(to):
				continue
			if MovementRules.is_square_occupied_by_ally(to, piece, pieces):
				continue
			valid_moves.append(to)

	return valid_moves


func _add_pawn_moves(start_position: Vector2i, piece: Piece, valid_moves: Array[Vector2i]):
	var dir := -1 if piece.piece_color == Globals.PIECE_COLORS.WHITE else 1
	var start_row := 6 if piece.piece_color == Globals.PIECE_COLORS.WHITE else 1
	var forward = Vector2i(0, dir)
	
	# One step forward
	var one_step = start_position + forward
	if Rect2i(0, 0, 8, 8).has_point(one_step) and not MovementRules.is_square_occupied(one_step, piece, pieces):
		valid_moves.append(one_step)
		# Two steps forward if on starting row
		if start_position.y == start_row:
			var two_step = start_position + forward * 2
			if not MovementRules.is_square_occupied(two_step, piece, pieces):
				valid_moves.append(two_step)
	
	# Diagonal eats
	for dx in [-1, 1]:
		var diag = start_position + Vector2i(dx, dir)
		if Rect2i(0, 0, 8, 8).has_point(diag) and MovementRules.is_square_occupied_by_rival(diag, piece, pieces):
			valid_moves.append(diag)
