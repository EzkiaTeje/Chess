extends Node2D


var piece_scene = preload("res://scenes/piece/piece.tscn")

func _ready() -> void:
	_create_pieces()


func _create_pieces():
	var piece_instance = piece_scene.instantiate()
	add_child(piece_instance)
	piece_instance.init_piece(Globals.PIECE_COLORS.BLACK, Globals.PIECE_TYPES.KNIGHT, Vector2i(0, 0))
	
	#var sprite = piece_instance.get_node("Sprite2D")
	#sprite.texture = load("res://assets/pieces_tilesheet.png")
