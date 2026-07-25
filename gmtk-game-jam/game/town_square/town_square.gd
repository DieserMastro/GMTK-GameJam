extends Game

const INTERACTABLE = preload("uid://cl8ho73h70m67")
const WATER_BOTTLE_OBJECT = preload("res://resources/objects/water_bottle_object.tres")
const WATER_DISPENSER_RESOURCE = preload("res://resources/interactables/water_dispenser.tres")
const WATER_GUY_DIALOGUE = preload(
	"res://resources/interactions/dialogues/water_guy_outside_dialogue.tres"
)
const WATER_GUY_SUCCESS_DIALOGUE = preload(
	"res://resources/dialogues/water_guy_success_dialogue.tres"
)
const WATER_GUY_FAIL_DIALOGUE = preload("res://resources/dialogues/water_guy_fail_dialogue.tres")
const WATER_GUY_NAME := "Water Guy"

@export_group("Water Mini Game")
@export var water_search_duration := 30.0
@export var water_reward := 5.0

var _water_dispenser: Interactable
var _is_carrying_dispenser := false

@onready var characters: Node2D = $Characters
@onready var water_guy: Interactable = $"Characters/Water Guy"
@onready var water_search_timer: Timer = $WaterSearchTimer
@onready var water_dispenser_spawns: Node2D = $WaterDispenserSpawns


func _ready() -> void:
	super()
	water_search_timer.wait_time = water_search_duration
	_spawn_player()
	_update_characters()
	GameManager.start_game_timer()
	fade_transition.fade_in()


func _exit_tree() -> void:
	GameManager.town_square_player_position = player.global_position


func _end() -> void:
	fade_transition.fade_out()


func _spawn_player() -> void:
	if GameManager.town_square_player_position.is_zero_approx():
		return

	player.global_position = GameManager.town_square_player_position


func _update_characters() -> void:
	for character in characters.get_children():
		if character is not Interactable or not character.interaction_resource:
			continue

		character.enabled = character.interaction_resource.is_available()


#region Water mini game
func _start_water_search() -> void:
	_spawn_water_dispenser()
	water_search_timer.start()


func _spawn_water_dispenser() -> void:
	var spawn_points := water_dispenser_spawns.get_children()

	if spawn_points.is_empty():
		push_error("No water dispenser spawn points found")
		return

	_water_dispenser = INTERACTABLE.instantiate()
	_water_dispenser.interactable_resource = WATER_DISPENSER_RESOURCE
	_water_dispenser.interacted.connect(_on_water_dispenser_interacted)
	add_child(_water_dispenser)
	_water_dispenser.global_position = spawn_points.pick_random().global_position


func _finish_water_search() -> void:
	water_search_timer.stop()
	_despawn_water_dispenser()
	GameManager.complete_mini_game(Main.SCENE.WATER_GAME)

	if _is_carrying_dispenser:
		_is_carrying_dispenser = false
		player.drop_object()
		water_guy.interaction_resource = WATER_GUY_DIALOGUE

	_update_characters()


func _despawn_water_dispenser() -> void:
	if not _water_dispenser:
		return

	_water_dispenser.queue_free()
	_water_dispenser = null


func _on_water_guy_interacted() -> void:
	if _is_carrying_dispenser:
		_finish_water_search()
		GameManager.drinks += water_reward
		DialogueManager.start_dialogue(WATER_GUY_SUCCESS_DIALOGUE, WATER_GUY_NAME)
		return

	if _water_dispenser or GameManager.is_mini_game_finished(Main.SCENE.WATER_GAME):
		return

	DialogueManager.dialogue_completed.connect(_start_water_search, CONNECT_ONE_SHOT)


func _on_water_dispenser_interacted() -> void:
	_is_carrying_dispenser = true
	player.give_object(WATER_BOTTLE_OBJECT)
	_despawn_water_dispenser()
	water_guy.interaction_resource = null


func _on_water_search_timer_timeout() -> void:
	_finish_water_search()
	DialogueManager.start_dialogue(WATER_GUY_FAIL_DIALOGUE, WATER_GUY_NAME)
#endregion
