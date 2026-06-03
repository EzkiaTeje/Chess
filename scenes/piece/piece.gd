extends CharacterBody2D


@export var _sprite: Sprite2D

var piece_type: Globals.PIECE_TYPES
var piece_color: Globals.PIECE_COLORS

var _tilesheet = load("res://assets/pieces_tilesheet.png")


func init_piece(starting_position: Array):
	# Variables for later
	piece_type = starting_position[1]
	piece_color = starting_position[0]
	
	# Move to board position
	position.x = starting_position[2] * 16
	position.y = starting_position[3] * 16
	
	# Select sprite
	_sprite.texture = _tilesheet
	_sprite.region_enabled = true
	_sprite.region_rect = Rect2(Globals.SPRITE_MAPPING[piece_color][piece_type].x * 16, Globals.SPRITE_MAPPING[piece_color][piece_type].y * 16, 16, 16)
