class_name Game
extends Node

@onready var fade_transition: FadeTransition = $FadeTransition


func _ready() -> void:
	fade_transition.fade_in_finished.connect(_on_fade_in_transition_finished)
	fade_transition.fade_out_finished.connect(_on_fade_out_transition_finished)
	GameManager.time_expired.connect(_on_time_expired)


## Override for logic that happens when game starts
func _start() -> void:
	pass


## Override for logic that happens when game ends
func _end() -> void:
	pass


## Override for logic that happens when game exits
func _exit() -> void:
	GameManager.reset_game_timer()
	GameManager.main.load_scene(Main.SCENE.TOWN_SQUARE)


func _on_fade_in_transition_finished() -> void:
	_start()


func _on_fade_out_transition_finished() -> void:
	_exit()


func _on_time_expired() -> void:
	_end()
