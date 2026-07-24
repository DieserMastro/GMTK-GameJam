class_name Player
extends CharacterBody2D

const SPEED := 150.0
const RUN_SPEED := 250.0
const ACCELERATION_WEIGHT := 0.075
const DECCELERATION_WEIGHT := 0.1

var _is_running := false
var _is_frozen := false
var _interactive: InteractiveComponent

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var object_hold_component: ObjectHoldComponent = $ObjectHoldComponent


func _physics_process(_delta: float):
	if _is_frozen:
		return

	_movement()
	move_and_slide()


func _unhandled_key_input(event: InputEvent) -> void:
	if _is_frozen:
		return

	if event.is_action_pressed("run"):
		_is_running = true

	if event.is_action_released("run"):
		_is_running = false

	if event.is_action_pressed("interact") and _interactive:
		_interact()


#region Giving
func give_object(object_resource: ObjectResource) -> void:
	object_hold_component.spawn(object_resource)


func drop_object() -> void:
	object_hold_component.drop()
#endregion


#region Interactives
func set_interactive(interactive: InteractiveComponent) -> void:
	_interactive = interactive


func unset_interactive() -> void:
	_interactive = null
#endregion


#region Freeze
func freeze() -> void:
	_is_frozen = true


func unfreeze() -> void:
	_is_frozen = false
#endregion


func _movement() -> void:
	var direction := Input.get_vector("left", "right", "up", "down")

	_process_sprite(direction)

	if direction.is_zero_approx():
		velocity = velocity.lerp(Vector2.ZERO, DECCELERATION_WEIGHT)

	sprite.speed_scale = 1.2 if _is_running else 1.0
	var speed := RUN_SPEED if _is_running else SPEED
	velocity = velocity.lerp(direction * speed, ACCELERATION_WEIGHT)


func _process_sprite(direction: Vector2) -> void:
	if not is_zero_approx(direction.x):
		sprite.flip_h = direction.x < 0

	if direction.length() > 0:
		sprite.play("walk")
	else:
		sprite.play("idle")


func _interact() -> void:
	_interactive.interact()
