extends MiniGame

enum STATE {
	DIALOGUE,
	MIXING,
	OVEN_FREE,
	OVEN_BUSY,
	OVEN_DONE,
	GARNISH,
	SHOWCASE,
	DONE,
}

const OVEN_FREE = preload("uid://cej0srahq64yr")
const OVEN_BUSY = preload("uid://dyfybcescfaq8")
const OVEN_READY = preload("uid://brkm7tw42siq1")
const CAKE_OBJECT = preload("uid://c8fkav6qrxu1c")
const CAKE_READY_OBJECT = preload("uid://dk4wbgbpof2cr")
const TABLE_MINI_GAME_PACKED := preload("uid://c3thcmvc25bv6")
const MIXTURE_OBJECT_RESOURCE = preload("uid://dd4by80jhcg6w")
const OBJECT = preload("uid://bgn0vyn0uq0ix")
const KITCHEN_CAKE_FAIL_DIALOGUE = preload("uid://b5e5kw1415kwb")
const KITCHEN_MIXTURE_FAIL_DIALOGUE = preload("uid://dqg0vrptjnnyw")
const KITCHEN_TIME_OUT_DIALOGUE = preload("uid://bmxqiobogroxb")
const CHEF_NAME := "Chef"
const CAREFUL_STATES := [STATE.OVEN_FREE, STATE.GARNISH]
const CAREFUL_RECOVERY_RATE := 2.0
const CAREFUL_SAFE_COLOR := Color(0.537, 1.0, 0.537)
const CAREFUL_DANGER_COLOR := Color(1.0, 0.4, 0.4)
const CAREFUL_BAR_BACKGROUND_COLOR := Color(0.11, 0.11, 0.13, 0.9)


@export_group("Properties")
@export var oven_cooking_duration := 10.0
@export var game_duration := 90.0
@export var cake_supply_reward := 50.0
@export_group("Player")
@export var player_maximum_cake_speed := 90.0
@export var careful_grace_duration := 0.4

var _state := STATE.DIALOGUE
var _table_mini_game: KitchenTableMiniGame
var _showcase_cake_markers = []
var _reckless_time := 0.0
var _careful_bar_fill: StyleBoxFlat

@onready var table: Interactable = $Table
@onready var oven: Interactable = $Oven
@onready var showcase: Interactable = $Showcase
@onready var chef: Interactable = $Chef
@onready var table_layer: CanvasLayer = $TableLayer
@onready var careful_progress_bar: ProgressBar = $HUD/CarefulProgressBar
@onready var oven_timer: Timer = $Oven/OvenTimer
@onready var game_timer: Timer = $GameTimer
@onready var clock: Clock = $Clock


func _ready() -> void:
	super()
	_style_careful_progress_bar()
	_change_state(STATE.DIALOGUE)
	oven_timer.wait_time = oven_cooking_duration
	game_timer.wait_time = game_duration
	clock.follow(game_timer)
	_showcase_cake_markers = $Showcase/ShowcaseCakeMarkers.get_children()


func _physics_process(delta: float) -> void:
	if _state not in CAREFUL_STATES:
		return

	var is_too_fast := player.velocity.length() > player_maximum_cake_speed
	var change := delta if is_too_fast else -delta * CAREFUL_RECOVERY_RATE
	_reckless_time = clampf(_reckless_time + change, 0.0, careful_grace_duration)
	_update_careful_progress_bar()

	if _reckless_time >= careful_grace_duration:
		_drop_carried_object()


func _change_state(new_state: STATE) -> void:
	match new_state:
		STATE.DIALOGUE:
			table_layer.hide()
			careful_progress_bar.hide()
			table.disable()
			oven.disable()
			showcase.disable()
			chef.enable()
		STATE.MIXING:
			oven.disable()
			showcase.disable()
			chef.disable()
			table.enable()
			careful_progress_bar.hide()
			_reset_carefulness()
		STATE.OVEN_FREE:
			oven.enable()
			table.disable()
			oven.set_resource(OVEN_FREE)
			_reset_carefulness()
			careful_progress_bar.show()
		STATE.OVEN_BUSY:
			careful_progress_bar.hide()
			oven.disable()
			table.disable()
			oven_timer.start()
			oven.set_resource(OVEN_BUSY)
		STATE.OVEN_DONE:
			oven.enable()
			oven.set_resource(OVEN_READY)
		STATE.GARNISH:
			table.enable()
			oven.set_resource(OVEN_FREE)
			_reset_carefulness()
			careful_progress_bar.show()
		STATE.SHOWCASE:
			careful_progress_bar.hide()
			table.disable()
			showcase.enable()
		STATE.DONE:
			game_timer.stop()
			oven_timer.stop()
			clock.retract()
			careful_progress_bar.hide()
			_close_table_mini_game()
			player.drop_object()
			table.disable()
			showcase.disable()
			oven.disable()
			oven.set_resource(OVEN_FREE)
			chef.enable()
			_complete()

	_state = new_state


func _exit() -> void:
	GameManager.main.load_scene(Main.SCENE.TOWN_SQUARE)


func _close_table_mini_game() -> void:
	if not _table_mini_game:
		return

	_table_mini_game.queue_free()
	_on_table_mini_game_exited()


func _drop_carried_object() -> void:
	var fail_dialogue := (
		KITCHEN_MIXTURE_FAIL_DIALOGUE if _state == STATE.OVEN_FREE else KITCHEN_CAKE_FAIL_DIALOGUE
	)

	player.drop_object()
	_change_state(STATE.MIXING)
	DialogueManager.start_dialogue(fail_dialogue, CHEF_NAME)


func _reset_carefulness() -> void:
	_reckless_time = 0.0
	_update_careful_progress_bar()


func _style_careful_progress_bar() -> void:
	careful_progress_bar.max_value = careful_grace_duration
	careful_progress_bar.show_percentage = false

	_careful_bar_fill = _make_careful_bar_style(CAREFUL_SAFE_COLOR)
	careful_progress_bar.add_theme_stylebox_override(
		"background", _make_careful_bar_style(CAREFUL_BAR_BACKGROUND_COLOR)
	)
	careful_progress_bar.add_theme_stylebox_override("fill", _careful_bar_fill)


func _make_careful_bar_style(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(3)
	return style


func _update_careful_progress_bar() -> void:
	var reckless_ratio := _reckless_time / careful_grace_duration
	careful_progress_bar.value = _reckless_time
	_careful_bar_fill.bg_color = CAREFUL_SAFE_COLOR.lerp(CAREFUL_DANGER_COLOR, reckless_ratio)


func _on_chef_interacted() -> void:
	match _state:
		STATE.DIALOGUE:
			game_timer.start()
			clock.drop_in()
			_change_state(STATE.MIXING)
		STATE.DONE:
			DialogueManager.dialogue_completed.connect(_end, CONNECT_ONE_SHOT)


func _on_table_interacted() -> void:
	if _table_mini_game:
		return

	player.freeze()

	_table_mini_game = TABLE_MINI_GAME_PACKED.instantiate()
	_table_mini_game.mixture_ready.connect(_on_mixture_ready)
	_table_mini_game.cake_complete.connect(_on_cake_complete)
	_table_mini_game.exited.connect(_on_table_mini_game_exited)
	_table_mini_game.should_limit_camera = false
	table_layer.add_child(_table_mini_game)
	var table_phase := KitchenTableMiniGame.STATE.MIXTURE_PHASE if _state == STATE.MIXING else KitchenTableMiniGame.STATE.GARNISH_PHASE
	_table_mini_game.spawn(table_phase)
	table_layer.show()


func _on_mixture_ready() -> void:
	_change_state(STATE.OVEN_FREE)
	player.give_object(MIXTURE_OBJECT_RESOURCE)


func _on_cake_complete() -> void:
	_change_state(STATE.SHOWCASE)
	player.give_object(CAKE_READY_OBJECT)


func _on_table_mini_game_exited() -> void:
	_table_mini_game = null
	table_layer.hide()
	player.unfreeze()


func _on_oven_interacted() -> void:
	match _state:
		STATE.OVEN_DONE:
			_change_state(STATE.GARNISH)
			player.give_object(CAKE_OBJECT)
		STATE.OVEN_FREE:
			_change_state(STATE.OVEN_BUSY)
			player.drop_object()


func _on_oven_timer_timeout() -> void:
	_change_state(STATE.OVEN_DONE)


func _on_game_timer_timeout() -> void:
	_change_state(STATE.DONE)
	DialogueManager.start_dialogue(KITCHEN_TIME_OUT_DIALOGUE, CHEF_NAME)


func _on_showcase_interacted() -> void:
	if _state != STATE.SHOWCASE:
		return

	player.drop_object()
	_display_cake()
	GameManager.supplies += cake_supply_reward

	if _is_showcase_full():
		_change_state(STATE.DONE)
	else:
		_change_state(STATE.MIXING)


func _display_cake() -> void:
	for cake_marker in _showcase_cake_markers:
		if cake_marker.get_child_count() > 0:
			continue

		var cake: GameObject = OBJECT.instantiate()
		cake.object_resource = CAKE_READY_OBJECT
		cake_marker.add_child(cake)
		cake.small()
		return


func _is_showcase_full() -> bool:
	for cake_marker in _showcase_cake_markers:
		if cake_marker.get_child_count() == 0:
			return false

	return true
