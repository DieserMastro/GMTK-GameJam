class_name Player
extends CharacterBody2D

const SPEED := 300.0
const RUN_SPEED := 500.0

var _is_running := false
var _is_interacting := false
var _interactive: InteractiveComponent


func _physics_process(_delta: float):
	if _is_interacting:
		return

	_movement()
	move_and_slide()


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("run"):
		_is_running = true

	if event.is_action_released("run"):
		_is_running = false

	if event.is_action_pressed("interact") and _interactive:
		_interact()


func set_interactive(interactive: InteractiveComponent) -> void:
	_interactive = interactive


func unset_interactive() -> void:
	_is_interacting = false
	_interactive = null


func _movement() -> void:
	var direction := Input.get_vector("left", "right", "up", "down")
	if _is_running:
		velocity = direction * RUN_SPEED
		return

	velocity = direction * SPEED


func _interact() -> void:
	_is_interacting = not _is_interacting
	_interactive.interact()
