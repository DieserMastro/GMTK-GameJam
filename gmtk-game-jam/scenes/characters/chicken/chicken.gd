class_name Chicken
extends Node2D

signal caught

const SPEED_OFFSET := 10.0
const MAXIMUM_FLEE_ANGLE := PI / 4
const FLEE_CHANGE_INTERVAL := 0.6

var _speed := 0.0
var _flee_angle := 0.0
var _flee_change_countdown := 0.0
var _is_active := false
var _player: Player
var _bounds: Rect2

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


func _physics_process(delta: float) -> void:
	if not _is_active or not _player:
		return

	_flee_change_countdown -= delta

	if _flee_change_countdown <= 0.0:
		_randomize_flee()

	var away_direction := (global_position - _player.global_position).normalized()
	_move(away_direction.rotated(_flee_angle), delta)


func set_bounds(bounds: Rect2) -> void:
	_bounds = bounds


func enable() -> void:
	_is_active = true

	if _player:
		_run_away()


func _run_away() -> void:
	_randomize_flee()
	sprite.play("run")


func _randomize_flee() -> void:
	var min_speed := Player.RUN_SPEED - (SPEED_OFFSET * 2)
	var max_speed := Player.RUN_SPEED + SPEED_OFFSET
	_speed = randf_range(min_speed, max_speed)
	_flee_angle = randf_range(-MAXIMUM_FLEE_ANGLE, MAXIMUM_FLEE_ANGLE)
	_flee_change_countdown = FLEE_CHANGE_INTERVAL


func _calm_down() -> void:
	sprite.play("idle")


func _move(direction: Vector2, delta: float) -> void:
	global_position += direction * _speed * delta
	global_position = global_position.clamp(_bounds.position, _bounds.end)

	if not is_zero_approx(direction.x):
		sprite.flip_h = direction.x < 0


func _on_detection_area_body_entered(body: Player) -> void:
	_player = body

	if not _is_active:
		return

	_run_away()


func _on_detection_area_body_exited(_body: Player) -> void:
	_player = null
	_calm_down()


func _on_interactive_component_interacted() -> void:
	caught.emit()
	queue_free()
