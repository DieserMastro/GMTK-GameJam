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


@export_group("Properties")
@export var oven_cooking_duration := 10.0
@export var food_reward := 5.0
@export_group("Player")
@export var player_maximum_cake_speed := 90.0

var _state := STATE.DIALOGUE
var _table_mini_game: KitchenTableMiniGame
var _showcase_cake_markers = []

@onready var table: Interactable = $Table
@onready var oven: Interactable = $Oven
@onready var showcase: Interactable = $Showcase
@onready var chef: Interactable = $Chef
@onready var table_layer: CanvasLayer = $TableLayer
@onready var careful_progress_bar: ProgressBar = $HUD/CarefulProgressBar
@onready var oven_timer: Timer = $Oven/OvenTimer

 
func _ready() -> void:
	super()
	_change_state(STATE.DIALOGUE)
	careful_progress_bar.max_value = player_maximum_cake_speed
	oven_timer.wait_time = oven_cooking_duration
	_showcase_cake_markers = $Showcase/ShowcaseCakeMarkers.get_children()


func _physics_process(_delta: float) -> void:
	match _state:
		STATE.OVEN_FREE, STATE.GARNISH:
			careful_progress_bar.value = player.velocity.length()
			if player.velocity.length() > player_maximum_cake_speed:
				_reset()


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
			careful_progress_bar.value = 0.0
		STATE.OVEN_FREE:
			oven.enable()
			table.disable()
			careful_progress_bar.show()
			oven.set_resource(OVEN_FREE)
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
			careful_progress_bar.show()
		STATE.SHOWCASE:
			careful_progress_bar.hide()
			table.disable()
			showcase.enable()
		STATE.DONE:
			table.disable()
			showcase.disable()
			oven.disable()
			chef.enable()
			_complete()

	_state = new_state


func _end() -> void:
	super()
	GameManager.main.load_scene(Main.SCENE.TOWN_SQUARE)


func _reset() -> void:
	_change_state(STATE.MIXING)
	player.drop_object()


func _on_chef_interacted() -> void:
	match _state:
		STATE.DIALOGUE:
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


func _on_showcase_interacted() -> void:
	player.drop_object()
	_display_cake()

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
