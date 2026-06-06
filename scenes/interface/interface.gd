extends Control


@onready var white_time_label = $MarginContainer/VBoxContainer/WhiteTimeLabel
@onready var black_time_label = $MarginContainer/VBoxContainer/BlackTimeLabel
@onready var turn_label = $MarginContainer/VBoxContainer/Turn

var _white_time := 180
var _black_time := 180


func _ready() -> void:
	var game_node = get_node("/root/Game")
	game_node.turn_changed.connect(_on_turn_changed)
	game_node.game_ended.connect(_on_game_ended)


func _on_turn_changed(turn: int) -> void:
	if turn == Globals.PIECE_COLORS.WHITE:
		$BlackTimer.stop()
		$WhiteTimer.start()
		turn_label.text = "WHITE TURN"
		turn_label.add_theme_color_override("font_color", Color.WHITE)
	else:
		$WhiteTimer.stop()
		$BlackTimer.start()
		turn_label.text = "BLACK TURN"
		turn_label.add_theme_color_override("font_color", Color.BLACK)


func _on_game_ended(winner: String) -> void:
	if winner == "WHITE":
		turn_label.text = "WHITE WON!"
	else:
		turn_label.text = "BLACK WON!"


func _on_start_button_pressed() -> void:
	$WhiteTimer.start()
	$StartButton.visible = false
	set_mouse_filter(MOUSE_FILTER_IGNORE)


func _on_white_timer_timeout() -> void:
	_white_time -= 1
	_update_display()


func _on_black_timer_timeout() -> void:
	_black_time -= 1
	_update_display()


func _update_display() -> void:
	var minutes = _white_time / 60.0
	var seconds = _white_time % 60
	white_time_label.text = "%d:%02d" % [minutes, seconds]
	minutes = _black_time / 60.0
	seconds = _black_time % 60
	black_time_label.text = "%d:%02d" % [minutes, seconds]
