class_name MiniGame
extends Node

const DEFAULT_MINI_GAME_DURATION := 10.0

@export_group("Properties")
@export var duration := DEFAULT_MINI_GAME_DURATION

@onready var fade_transition: FadeTransition = $HUD/FadeTransition
@onready var mini_game_timer: Timer = $MiniGameTimer


func _ready() -> void:
	fade_transition.fade_in_finished.connect(_on_fade_in_transition_finished)
	fade_transition.fade_out_finished.connect(_on_fade_out_transition_finished)

	fade_transition.fade_in()
	mini_game_timer.wait_time = duration


## Override for logic that happens when mini game starts
func _start() -> void:
	mini_game_timer.start()


## Override for logic that happens when mini game ends
func _end() -> void:
	fade_transition.fade_out()


## Override for logic that happens when mini game exits
func _exit() -> void:
	pass


func _on_fade_in_transition_finished() -> void:
	_start()


func _on_mini_game_timer_timeout() -> void:
	_end()


func _on_fade_out_transition_finished() -> void:
	_exit()
