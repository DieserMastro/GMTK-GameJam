class_name Game
extends Node2D

@onready var fade_transition: FadeTransition = $FadeTransition
@onready var hud: HUD = $HUD


func _ready() -> void:
	print("%s entering" % name)
	fade_transition.fade_in_finished.connect(_on_fade_in_transition_finished)
	fade_transition.fade_out_finished.connect(_on_fade_out_transition_finished)
	GameManager.time_expired.connect(_on_time_expired)


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		_toggle_pause()


## Override for logic that happens when game starts
func _start() -> void:
	print("%s starting" % name)


## Override for logic that happens when game ends
func _end() -> void:
	print("%s ending" % name)


## Override for logic that happens when game exits
func _exit() -> void:
	print("%s exiting" % name)


func _toggle_pause() -> void:
	var is_paused := get_tree().paused

	if is_paused:
		hud.unpause()
		GameManager.pause_game_timer(false)
	else:
		hud.pause()
		GameManager.pause_game_timer(true)

	get_tree().paused = not get_tree().paused


func _on_fade_in_transition_finished() -> void:
	_start()


func _on_fade_out_transition_finished() -> void:
	_exit()


func _on_time_expired() -> void:
	_end()
