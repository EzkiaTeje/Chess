class_name Piece
extends Node2D


const _tilesheet = preload("res://assets/pieces_tilesheet.png")
var piece_type: Globals.PIECE_TYPES
var piece_color: Globals.PIECE_COLORS


func _ready() -> void:
	$Sprite2D.texture = _tilesheet


func init_piece(starting_position: Array):
	piece_type = starting_position[1]
	piece_color = starting_position[0]
	position.x = starting_position[2] * Globals.CELL_SIZE
	position.y = starting_position[3] * Globals.CELL_SIZE

	_update_sprite()


func _update_sprite():
	$Sprite2D.region_enabled = true
	$Sprite2D.region_rect = Rect2(Globals.SPRITE_MAPPING[piece_color][piece_type].x * Globals.CELL_SIZE,
		Globals.SPRITE_MAPPING[piece_color][piece_type].y * Globals.CELL_SIZE, Globals.CELL_SIZE, Globals.CELL_SIZE)


func move_piece(new_position: Vector2i):
	position.x = new_position.x * Globals.CELL_SIZE
	position.y = new_position.y * Globals.CELL_SIZE
