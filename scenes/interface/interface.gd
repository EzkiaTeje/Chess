extends Control


@onready var white_time_label = $MarginContainer/VBoxContainer/WhiteTimeLabel
@onready var black_time_label = $MarginContainer/VBoxContainer/BlackTimeLabel


func _ready() -> void:
	var game_node = get_node("/root/Game")
	game_node.turn_changed.connect(_on_turn_changed)


func _on_turn_changed(turn: int):
	if turn == Globals.PIECE_COLORS.WHITE:
		$BlackTimer.stop()
		$WhiteTimer.start()
	else:
		$WhiteTimer.stop()
		$BlackTimer.start()
