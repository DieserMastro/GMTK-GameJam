extends StaticBody2D

const RED_COLOR := Color(1.0, 0.494, 0.427, 1.0)
const GREEN_COLOR := Color(0.604, 1.0, 0.573, 1.0)
const YELLOW_COLOR := Color(1.0, 1.0, 0.0, 1.0)

var _colors := [RED_COLOR, GREEN_COLOR, YELLOW_COLOR]


func _ready() -> void:
	var should_change_color := randf() > 0.6
	if should_change_color:
		modulate = _colors.pick_random()
