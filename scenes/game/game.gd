extends Node2D

var _piece_scene = preload("res://scenes/piece/piece.tscn")
var starting_positions: Array = Globals.STARTING_POSITIONS

# Controller -> var actual_positions: Array


func _ready() -> void:
	_create_pieces()


func _create_pieces():
	var piece_instance
	
	for i in range(32):
		piece_instance = _piece_scene.instantiate()
		add_child(piece_instance)
		piece_instance.init_piece(Globals.STARTING_POSITIONS[i])
