extends MiniGame

enum STATE {
	PREPARE,
	CHASING,
	END,
}

const CHICKEN = preload("uid://durly01mavpvi")
const WORLD_LAYER := 4

@export_group("Properties")
@export var chicken_amount := 5
@export var game_duration := 30.0
@export_group("State")
@export var initial_state := STATE.PREPARE

var _state: STATE
var _chickens_left: int

@onready var fence_layer: TileMapLayer = $FenceLayer
@onready var chickens: Node2D = $Chickens
@onready var farmer: Interactable = $Farmer
@onready var fence_gate: StaticBody2D = $FenceGate
@onready var player_reset_marker: Marker2D = $PlayerResetMarker
@onready var game_timer: Timer = $GameTimer


func _ready() -> void:
	super()
	_change_state(initial_state)


func _end() -> void:
	super()
	GameManager.main.load_scene(Main.SCENE.TOWN_SQUARE)


func _change_state(new_state: STATE) -> void:
	match new_state:
		STATE.PREPARE:
			game_timer.wait_time = game_duration
			_spawn_chickens()
		STATE.CHASING:
			farmer.disable()
			_enable_chickens()
			_open_gate()
		STATE.END:
			_finish_game()

	_state = new_state


func _finish_game() -> void:
	game_timer.stop()
	player.global_position = player_reset_marker.global_position
	farmer.enable()
	_close_gate()
	_complete()


func _get_chicken_bounds() -> Rect2:
	var fence_rect := fence_layer.get_used_rect()
	var tile_size := Vector2(fence_layer.tile_set.tile_size)
	var fence_bounds_in_px := Rect2(
		Vector2(fence_rect.position) * tile_size,
		Vector2(fence_rect.size) * tile_size,
	)
	# Reduce by 1 tile so chickens won't go on top of fence
	return fence_bounds_in_px.grow(-tile_size.x)


func _spawn_chickens() -> void:
	var bounds := _get_chicken_bounds()
	for _i in chicken_amount:
		var chicken: Chicken = CHICKEN.instantiate()
		chicken.caught.connect(_on_chicken_caught)
		chicken.position = Vector2(
			randf_range(bounds.position.x, bounds.end.x),
			randf_range(bounds.position.y, bounds.end.y),
		)
		chicken.set_bounds(bounds)
		chickens.add_child(chicken)
		_chickens_left += 1


func _enable_chickens() -> void:
	for chicken: Chicken in chickens.get_children():
		chicken.enable()


func _open_gate() -> void:
	if GameManager.is_mini_game_finished(mini_game_scene):
		return

	fence_gate.hide()
	fence_gate.set_collision_layer_value(WORLD_LAYER, false)


func _close_gate() -> void:
	fence_gate.show()
	fence_gate.set_collision_layer_value(WORLD_LAYER, true)


func _on_chicken_caught() -> void:
	_chickens_left -= 1
	if _chickens_left > 0:
		return

	_change_state(STATE.END)


func _on_farmer_interacted() -> void:
	match _state:
		STATE.PREPARE:
			_change_state(STATE.CHASING)
		STATE.END:
			DialogueManager.dialogue_completed.connect(_end, CONNECT_ONE_SHOT)


func _on_game_timer_timeout() -> void:
	_change_state(STATE.END)


func _on_start_game_area_body_entered(_body: Node2D) -> void:
	game_timer.start()
