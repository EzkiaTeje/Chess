extends Node2D


var _piece_scene = preload("res://scenes/piece/piece.tscn")
var actual_positions = Globals.STARTING_POSITIONS.duplicate(true)
var pieces: Array[Piece]
var selected_piece: Piece
var current_turn := Globals.PIECE_COLORS.WHITE


func _ready() -> void:
	_create_pieces()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if not selected_piece:
			return

		var board_position := Vector2i(get_local_mouse_position() / 16)
		if board_position == Vector2i(selected_piece.position / 16):
			return

		for piece in pieces:
			if piece != selected_piece and Vector2i(piece.position / 16) == board_position:
				if piece.piece_color == selected_piece.piece_color:
					return
				if piece.piece_type == Globals.PIECE_TYPES.KING:
					if piece.piece_color == Globals.PIECE_COLORS.WHITE:
						$CanvasLayer/Interface/MarginContainer/VBoxContainer/Turn.text = "BLACK WON"
					else:
						$CanvasLayer/Interface/MarginContainer/VBoxContainer/Turn.text = "WHITE WON"
						$CanvasLayer/Interface/MarginContainer/VBoxContainer/Turn.text = "BLACK WON"
					piece.queue_free()
					pieces.erase(piece)
					selected_piece.move_piece(board_position)
					selected_piece.modulate = Color.WHITE
					process_mode = Node.PROCESS_MODE_DISABLED
					return
				piece.queue_free()
				pieces.erase(piece)
				break

		selected_piece.move_piece(board_position)
		selected_piece.modulate = Color.WHITE
		selected_piece = null

		if current_turn == Globals.PIECE_COLORS.BLACK:
			current_turn = Globals.PIECE_COLORS.WHITE
			$CanvasLayer/Interface/MarginContainer/VBoxContainer/Turn.text = "WHITE'S TURN"
			$CanvasLayer/Interface/MarginContainer/VBoxContainer/Turn.modulate = Color.WHITE
		else:
			current_turn = Globals.PIECE_COLORS.BLACK
			$CanvasLayer/Interface/MarginContainer/VBoxContainer/Turn.text = "BLACK'S TURN"
			$CanvasLayer/Interface/MarginContainer/VBoxContainer/Turn.modulate = Color.BLACK


func _create_pieces():
	for i in range(32):
		var piece_instance = _piece_scene.instantiate()
		add_child(piece_instance)
		piece_instance.init_piece(Globals.STARTING_POSITIONS[i])
		pieces.append(piece_instance)
		piece_instance.get_node("Area2D").input_event.connect(_on_piece_clicked.bind(piece_instance))


func _on_piece_clicked(_viewport: Node, event: InputEvent, _shape_idx: int, piece: Piece) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if piece.piece_color != current_turn:
			return
		if selected_piece == piece:
			selected_piece.modulate = Color.WHITE
			selected_piece = null
			return
		if selected_piece:
			selected_piece.modulate = Color.WHITE
		selected_piece = piece
		selected_piece.modulate = Color.GREEN
		
