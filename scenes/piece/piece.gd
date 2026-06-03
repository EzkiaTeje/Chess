extends CharacterBody2D


@export var sprite_node: Sprite2D

var piece_type: Globals.PIECE_TYPES
var piece_color: Globals.PIECE_COLORS
var piece_position: Vector2i


func _ready() -> void:
	pass


func init_piece(col: Globals.PIECE_COLORS, ty: Globals.PIECE_TYPES, pos: Vector2i):
	piece_type = ty
	piece_color = col
	piece_position = pos
	position = pos * 16
	
	sprite_node.texture = load("res://assets/pieces_tilesheet.png")
	sprite_node.region_enabled = true
	sprite_node.region_rect = Rect2(Globals.SPRITE_MAPPING[col][ty].x * 16, Globals.SPRITE_MAPPING[col][ty].y * 16, 16, 16)
