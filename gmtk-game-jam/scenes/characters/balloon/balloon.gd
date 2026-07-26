class_name Balloon
extends Node2D

signal popped()

const MIN_SPEED := 75.0
const MAX_SPEED := 150.0
const RED_COLOR := Color(1.0, 0.791, 0.94, 1.0)
const GREEN_COLOR := Color(0.675, 1.0, 0.667, 1.0)
const ORANGE_COLOR := Color(1.0, 0.799, 0.693, 1.0)
const IDK_COLOR := Color(0.69, 0.915, 1.0, 1.0)

var _speed: float
var _colors := [RED_COLOR, GREEN_COLOR, ORANGE_COLOR, IDK_COLOR]


func _ready() -> void:
	_randomize_speed()
	_randomize_color()


func _physics_process(delta: float) -> void:
	global_position += Vector2.UP * _speed * delta


func _randomize_speed() -> void:
	_speed = randf_range(MIN_SPEED, MAX_SPEED)


func _randomize_color() -> void:
	modulate = _colors.pick_random()


func _on_clickable_component_clicked() -> void:
	popped.emit()
	AudioManager.play_sfx(AudioManager.SFX.BALLOON_POP)
	queue_free()


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
