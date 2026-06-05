extends Node2D


@onready var _turn_label = $CanvasLayer/Interface/MarginContainer/VBoxContainer/Turn

var _piece_scene = preload("res://scenes/piece/piece.tscn")
var pieces: Array[Piece]
var selected_piece: Piece
var _current_turn := Globals.PIECE_COLORS.WHITE


func _ready() -> void:
	_create_pieces()


func _unhandled_input(event: InputEvent) -> void:
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
	if !_is_correct_movement(board_clicked_position):
		return
	if _is_piece_blocked(board_clicked_position):
		return
	if _try_eating(board_clicked_position):
		return

	selected_piece.move_piece(board_clicked_position)	
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
			if MovementRules.is_pawn_movement_occupied(start_position, selected_piece, pieces):
				return true
		Globals.PIECE_TYPES.ROOK, Globals.PIECE_TYPES.BISHOP, Globals.PIECE_TYPES.QUEEN:
			if MovementRules.is_rook_bishop_queen_movement_occupied(board_clicked_position, start_position, movement_delta, selected_piece, pieces):
				return true
	return false

#
#func _is_square_occupied(board_position: Vector2i) -> bool:
	#for piece in pieces:
		#if piece == selected_piece:
			#continue
		#if Vector2i(piece.position / Globals.CELL_SIZE) == board_position:
			#return true
	#return false


func _end_game(lost_color: int) -> void:
	var winner = "BLACK" if lost_color == Globals.PIECE_COLORS.WHITE else "WHITE"
	_turn_label.text = winner + " WON"


func _deselect() -> void:
	if selected_piece:
		selected_piece.modulate = Color.WHITE
	selected_piece = null


func _switch_turn() -> void:
	if _current_turn == Globals.PIECE_COLORS.BLACK:
		_current_turn = Globals.PIECE_COLORS.WHITE
		_turn_label.text = "WHITE'S TURN"
		_turn_label.modulate = Color.WHITE
	else:
		_current_turn = Globals.PIECE_COLORS.BLACK
		_turn_label.text = "BLACK'S TURN"
		_turn_label.modulate = Color.BLACK


func _create_pieces():
	for i in range(Globals.TOTAL_PIECES):
		var piece_instance = _piece_scene.instantiate()
		add_child(piece_instance)
		pieces.append(piece_instance)
		piece_instance.init_piece(Globals.STARTING_POSITIONS[i])
		piece_instance.get_node("Area2D").input_event.connect(_on_piece_clicked.bind(piece_instance))


func _on_piece_clicked(_viewport: Node, event: InputEvent, _shape_idx: int, piece: Piece) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if piece.piece_color != _current_turn:
			return
		
		if selected_piece == piece:
			_deselect()
			return
		
		if selected_piece:
			_deselect()
		
		selected_piece = piece
		selected_piece.modulate = Color.GREEN
