extends Node

signal time_left_changed(time_left: int)
signal run_over
signal time_expired
signal supplies_changed(supplies: float)
signal money_changed(money: float)

const DEFAULT_TIME_LEFT_IN_S := 300
const FESTIVAL_TIME_DIALOGUE = preload("uid://cajh1oxmjgqok")
const MAYOR_NAME := "Mayor"

var supplies := 0.0:
	set(value):
		supplies = value
		supplies_changed.emit(supplies)
var money := 0.0:
	set(value):
		money = value
		money_changed.emit(money)
var time_left := DEFAULT_TIME_LEFT_IN_S
var finished_mini_games: Array[Main.SCENE] = []

var main: Main
var town_square_player_position := Vector2.ZERO

var _is_run_over := false
var _is_outcome_requested := false

@onready var game_timer: Timer = $GameTimer


func _ready() -> void:
	game_timer.wait_time = 1.0


func reset_run() -> void:
	supplies = 0.0
	money = 0.0
	finished_mini_games.clear()
	town_square_player_position = Vector2.ZERO
	game_timer.stop()
	time_left = DEFAULT_TIME_LEFT_IN_S
	_is_run_over = false
	_is_outcome_requested = false


func complete_mini_game(mini_game: Main.SCENE) -> void:
	if is_mini_game_finished(mini_game):
		return

	finished_mini_games.append(mini_game)


func is_mini_game_finished(mini_game: Main.SCENE) -> bool:
	return finished_mini_games.has(mini_game)


func is_run_over() -> bool:
	return _is_run_over


func show_outcome() -> void:
	if _is_outcome_requested:
		return

	_is_outcome_requested = true
	main.load_scene(Main.SCENE.OUTCOME)


func start_game_timer() -> void:
	time_left_changed.emit(time_left)
	game_timer.start()


func reset_game_timer() -> void:
	game_timer.stop()
	time_left = DEFAULT_TIME_LEFT_IN_S
	game_timer.start()


func pause_game_timer(pause: bool) -> void:
	game_timer.paused = pause


func _on_game_timer_timeout() -> void:
	time_left = max(0, time_left - 1)
	time_left_changed.emit(time_left)

	if time_left == 0:
		game_timer.stop()
		_is_run_over = true
		run_over.emit()
		_announce_festival()


func _announce_festival() -> void:
	DialogueManager.stop_dialogue()

	if FESTIVAL_TIME_DIALOGUE.lines.is_empty():
		time_expired.emit()
		return

	DialogueManager.dialogue_completed.connect(time_expired.emit, CONNECT_ONE_SHOT)
	DialogueManager.start_dialogue(FESTIVAL_TIME_DIALOGUE, MAYOR_NAME)
