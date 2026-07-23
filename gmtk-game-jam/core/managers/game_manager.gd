extends Node

signal time_left_changed(time_left: int)
signal time_expired

const DEFAULT_TIME_LEFT_IN_S := 5

var money := 0
var food := 0
var drinks := 0
var score := 0
var time_left := DEFAULT_TIME_LEFT_IN_S

var main: Main

@onready var game_timer: Timer = $GameTimer


func _ready() -> void:
	game_timer.wait_time = 1.0


func start_game_timer() -> void:
	time_left = DEFAULT_TIME_LEFT_IN_S
	time_left_changed.emit(time_left)
	game_timer.start()


func reset_game_timer() -> void:
	game_timer.stop()
	time_left = DEFAULT_TIME_LEFT_IN_S
	game_timer.start()


func _on_game_timer_timeout() -> void:
	time_left -= 1
	time_left_changed.emit(time_left)

	if time_left <= 0:
		game_timer.stop()
		time_expired.emit()
