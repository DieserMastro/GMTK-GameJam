extends MiniGame

const TABLE_MINI_GAME_PACKED := preload("uid://c3thcmvc25bv6")
const OVEN_READY_RESOURCE = preload("uid://dyfybcescfaq8")
const MIXTURE_OBJECT = preload("uid://dd4by80jhcg6w")
const CAKE_OBJECT = preload("uid://c8fkav6qrxu1c")

@export_group("Properties")
@export var oven_cooking_duration := 10.0
@export var food_reward := 5.0
@export_group("Player")
@export var player_maximum_cake_speed := 100.0

var _table_mini_game: KitchenTableMiniGame
var _mixture_ready := false
var _cake_ready := false
var _cake_complete := false

@onready var table: Interactable = $Table
@onready var oven: Interactable = $Oven
@onready var table_layer: CanvasLayer = $TableLayer
@onready var player: Player = $Player
@onready var careful_progress_bar: ProgressBar = $HUD/CarefulProgressBar
@onready var oven_timer: Timer = $Oven/OvenTimer


func _ready() -> void:
	super()
	table_layer.hide()

	careful_progress_bar.max_value = player.SPEED
	careful_progress_bar.hide()

	oven_timer.wait_time = oven_cooking_duration


func _process(_delta: float) -> void:
	if not _mixture_ready or not oven.enabled or not table.enabled:
		return

	careful_progress_bar.value = player.velocity.length()

	if careful_progress_bar.value > player_maximum_cake_speed:
		print("Too fast, dropped mixture or cake, resetting minigame")
		_reset()


func _end() -> void:
	super()
	GameManager.main.load_scene(Main.SCENE.TOWN_SQUARE)


func _reset() -> void:
	player.drop_object()
	oven.enabled = false
	table.enabled = true
	_mixture_ready = false
	_cake_ready = false
	_cake_complete = false


func _on_chef_interacted() -> void:
	print("Spoke to chef, enabling table")
	table.enabled = true


func _on_table_interacted() -> void:
	if _table_mini_game:
		return

	player.freeze()

	_table_mini_game = TABLE_MINI_GAME_PACKED.instantiate()
	_table_mini_game.mixture_ready.connect(_on_mixture_ready)
	_table_mini_game.cake_complete.connect(_on_cake_complete)
	_table_mini_game.exited.connect(_on_table_mini_game_exited)
	table_layer.add_child(_table_mini_game)
	_table_mini_game.spawn({ "mixture_ready": _mixture_ready })
	table_layer.show()


func _on_mixture_ready() -> void:
	_mixture_ready = true
	oven.enabled = true
	player.give_object(MIXTURE_OBJECT)
	careful_progress_bar.show()


func _on_cake_complete() -> void:
	GameManager.food += food_reward
	_cake_complete = true


func _on_table_mini_game_exited() -> void:
	_table_mini_game = null
	table_layer.hide()
	player.unfreeze()

	if _cake_complete:
		_end()


func _on_oven_interacted() -> void:
	if not _mixture_ready or not oven_timer.is_stopped():
		return

	if _cake_ready:
		print("Giving cake to player, enabling table!")
		table.enabled = true
		player.give_object(CAKE_OBJECT)
		return

	print("Oven starting, disabling table & oven, dropping cake")
	oven_timer.start()
	table.enabled = false
	oven.enabled = false
	player.drop_object()


func _on_oven_timer_timeout() -> void:
	print("Cake is ready, enabling  oven")
	oven.interactable_resource = OVEN_READY_RESOURCE
	_cake_ready = true
	oven.enabled = true
