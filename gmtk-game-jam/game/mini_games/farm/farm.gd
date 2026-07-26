extends MiniGame

enum STATE {
	PREPARE,
	CHASING,
	END,
}

const CHICKEN = preload("uid://durly01mavpvi")
const FARM_TIME_OUT_DIALOGUE = preload("uid://bv7g8uf7i3yiv")
const FARMER_NAME := "Farmer"
const WORLD_LAYER := 4
const CHICKEN_SOUND_MINIMUM := 1.5
const CHICKEN_SOUND_MAXIMUM := 6.0

@export_group("Properties")
@export var chicken_amount := 5
@export var game_duration := 30.0
@export var chicken_supply_reward := 12.0
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
@onready var clock: Clock = $Clock
@onready var chicken_sound_timer: Timer = $ChickenSoundTimer


func _ready() -> void:
	super()
	game_timer.wait_time = game_duration
	clock.follow(game_timer)
	_change_state(initial_state)


func _exit() -> void:
	GameManager.main.load_scene(Main.SCENE.TOWN_SQUARE)


func _change_state(new_state: STATE) -> void:
	match new_state:
		STATE.PREPARE:
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
	clock.retract()
	_disable_chickens()
	player.teleport_to(player_reset_marker.global_position)
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


func _disable_chickens() -> void:
	for chicken: Chicken in chickens.get_children():
		chicken.disable()


func _open_gate() -> void:
	if GameManager.is_mini_game_finished(mini_game_scene):
		return

	fence_gate.hide()
	fence_gate.set_collision_layer_value(WORLD_LAYER, false)


func _close_gate() -> void:
	fence_gate.show()
	fence_gate.set_collision_layer_value(WORLD_LAYER, true)


func _on_chicken_caught() -> void:
	if _state == STATE.END:
		return

	GameManager.supplies += chicken_supply_reward
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
	DialogueManager.start_dialogue(FARM_TIME_OUT_DIALOGUE, FARMER_NAME)


func _on_start_game_area_body_entered(_body: Node2D) -> void:
	if _state != STATE.CHASING or not game_timer.is_stopped():
		return

	game_timer.start()
	clock.drop_in()


func _on_chicken_sound_timer_timeout() -> void:
	AudioManager.play_sfx(AudioManager.SFX.CHICKEN)
	chicken_sound_timer.start(randf_range(CHICKEN_SOUND_MINIMUM, CHICKEN_SOUND_MAXIMUM))
