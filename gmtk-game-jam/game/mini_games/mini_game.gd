class_name MiniGame
extends Game

signal exited


func _ready() -> void:
	super()
	fade_transition.fade_in()


func _unhandled_key_input(event: InputEvent) -> void:
	super(event)


func _end() -> void:
	super()
	fade_transition.fade_out()


func _exit() -> void:
	exited.emit()
