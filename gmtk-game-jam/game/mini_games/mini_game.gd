class_name MiniGame
extends Game

signal exited

@export_group("Mini Game")
@export var mini_game_scene: Main.SCENE

var _can_exit_manually := false


func _ready() -> void:
	super()
	fade_transition.fade_in()


func _start() -> void:
	super()
	_can_exit_manually = true


func _complete() -> void:
	GameManager.complete_mini_game(mini_game_scene)


func _end() -> void:
	super()
	fade_transition.fade_out()


func _exit() -> void:
	exited.emit()
