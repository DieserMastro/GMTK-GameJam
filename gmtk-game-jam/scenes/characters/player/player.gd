extends CharacterBody2D

const SPEED := 300.0
const RUN_SPEED := 500.0

var _is_running := false

@onready var interaction_range: Area2D = $InteractionRange


func _physics_process(_delta: float):
	_movement()
	move_and_slide()


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("run"):
		_is_running = true

	if event.is_action_released("run"):
		_is_running = false

	if event.is_action_pressed("interact"):
		GameManager.main.load_scene(Main.SCENE.MINI_GAME)


func _movement():
	var direction := Input.get_vector("left", "right", "up", "down")
	if _is_running:
		velocity = direction * RUN_SPEED
		return

	velocity = direction * SPEED
