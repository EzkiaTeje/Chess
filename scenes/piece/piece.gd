class_name Piece
extends Node2D

var _tilesheet = load("res://assets/pieces_tilesheet.png")
var piece_type: Globals.PIECE_TYPES
var piece_color: Globals.PIECE_COLORS


func init_piece(starting_position: Array):
	# Variables for later
	piece_type = starting_position[1]
	piece_color = starting_position[0]
	
	# Move to board position
	position.x = starting_position[2] * 16
	position.y = starting_position[3] * 16
	
	# Select sprite
	$Sprite2D.texture = _tilesheet
	$Sprite2D.region_enabled = true
	$Sprite2D.region_rect = Rect2(Globals.SPRITE_MAPPING[piece_color][piece_type].x * 16, Globals.SPRITE_MAPPING[piece_color][piece_type].y * 16, 16, 16)


func move_piece(new_position: Vector2i):
	position.x = new_position.x * 16
	position.y = new_position.y * 16
