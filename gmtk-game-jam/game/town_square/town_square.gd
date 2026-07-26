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
const FINISH_PROMPT_DIALOGUE = preload("uid://d47lokkncn4v")
const OUTCOME_BAD = preload("uid://csg2o6y6l4hpn")
const OUTCOME_MID = preload("uid://n58vppfb4qwm")
const OUTCOME_WIN = preload("uid://chvq583433wwh")
const CROWD_SPRITE_FRAMES := [
	preload("res://resources/crowd/drunk_man_frames.tres"),
	preload("res://resources/crowd/kid_frames.tres"),
	preload("res://resources/crowd/kid_2_frames.tres"),
	preload("res://resources/crowd/woman_frames.tres"),
	preload("res://resources/crowd/woman2_frames.tres"),
]

@export_group("Water Mini Game")
@export var water_search_duration := 30.0
@export var water_supply_reward := 200.0
@export_group("Villagers")
@export var minimum_villagers := 10
@export var maximum_villagers := 20
@export_group("Outcome")
@export var outcomes: Array[OutcomeResource] = [OUTCOME_BAD, OUTCOME_MID, OUTCOME_WIN]
@export var camera_pan_duration := 12.0

var _water_dispenser: Interactable
var _is_carrying_dispenser := false
var _is_searching_water := false
var _outcome: OutcomeResource

@onready var characters: Node2D = $Characters
@onready var mayor: Interactable = $Characters/Mayor
@onready var water_guy: Interactable = $"Characters/Water Guy"
@onready var water_search_timer: Timer = $WaterSearchTimer
@onready var water_dispenser_spawns: Node2D = $WaterDispenserSpawns
@onready var clock: Clock = $ClockLayer/Clock
@onready var crowd: Node2D = $Crowd
@onready var crowd_markers: Node2D = $CrowdMarkers
@onready var pan_start: Marker2D = $PanStart
@onready var pan_end: Marker2D = $PanEnd


func _ready() -> void:
	super()

	if GameManager.is_showing_outcome:
		_setup_outcome()
		fade_transition.fade_in()
		return

	water_search_timer.wait_time = water_search_duration
	clock.follow(water_search_timer)
	_spawn_player()
	_spawn_crowd(randi_range(minimum_villagers, maximum_villagers))
	_update_characters()
	player.freeze()
	fade_transition.fade_in()


func _start() -> void:
	super()

	if GameManager.is_showing_outcome:
		_start_outcome()
		return

	if GameManager.is_intro_finished:
		player.unfreeze()
		GameManager.start_game_timer()
		return

	DialogueManager.dialogue_completed.connect(_on_mayor_intro_finished, CONNECT_ONE_SHOT)
	mayor.interaction_resource.interact(mayor)


func _on_mayor_intro_finished() -> void:
	GameManager.is_intro_finished = true
	GameManager.start_game_timer()


func _exit_tree() -> void:
	GameManager.town_square_player_position = player.global_position


func _end() -> void:
	fade_transition.fade_out()


func _spawn_player() -> void:
	if GameManager.town_square_player_position.is_zero_approx():
		return

	player.global_position = GameManager.town_square_player_position


func _spawn_crowd(amount: int) -> void:
	var markers := crowd_markers.get_children()
	markers.shuffle()

	for index in mini(amount, markers.size()):
		var villager := AnimatedSprite2D.new()
		villager.sprite_frames = CROWD_SPRITE_FRAMES.pick_random()
		crowd.add_child(villager)
		villager.global_position = markers[index].global_position
		villager.play("default")


func _update_characters() -> void:
	for character in characters.get_children():
		if character is not Interactable or not character.interaction_resource:
			continue

		if _is_searching_water:
			character.enabled = character == water_guy
			continue

		character.enabled = character.interaction_resource.is_available()


#region Water mini game
func _start_water_search() -> void:
	_is_searching_water = true
	_spawn_water_dispenser()
	water_search_timer.start()
	clock.drop_in()
	_update_characters()


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
	_is_searching_water = false
	water_search_timer.stop()
	clock.retract()
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
		GameManager.supplies += water_supply_reward
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


#region Outcome
func _setup_outcome() -> void:
	_outcome = _earned_outcome()
	hud.hide()
	player.hide()
	player.freeze()
	player.global_position = pan_start.global_position
	camera.position_smoothing_enabled = false
	_disable_characters()
	_spawn_crowd(_outcome.crowd_count)


func _start_outcome() -> void:
	create_tween().tween_property(
		player, "global_position", pan_end.global_position, camera_pan_duration
	)

	if not _outcome or not _outcome.dialogue:
		return

	DialogueManager.dialogue_completed.connect(_on_outcome_dialogue_completed, CONNECT_ONE_SHOT)
	DialogueManager.start_dialogue(_outcome.dialogue, _outcome.speaker_name)


func _earned_outcome() -> OutcomeResource:
	for index in range(outcomes.size() - 1, -1, -1):
		if outcomes[index].is_earned(GameManager.supplies, GameManager.money):
			return outcomes[index]

	return outcomes[0]


func _disable_characters() -> void:
	for character in characters.get_children():
		if character is Interactable:
			character.disable()


func _on_outcome_dialogue_completed() -> void:
	await fade_transition.fade_out()
	GameManager.main.load_scene(Main.SCENE.MAIN_MENU)
#endregion


func _on_finish_prompt_area_body_entered(body: Node2D) -> void:
	if GameManager.is_showing_outcome or body is not Player:
		return

	DialogueManager.start_dialogue(FINISH_PROMPT_DIALOGUE, GameManager.MAYOR_NAME)


func _on_finish_area_body_entered(body: Node2D) -> void:
	if GameManager.is_showing_outcome or body is not Player:
		return

	GameManager.finish_run()
