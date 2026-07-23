class_name MiniGame
extends Game


func _ready() -> void:
	super()
	fade_transition.fade_in()


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		GameManager.main.load_scene(Main.SCENE.TOWN_SQUARE)


func _end() -> void:
	fade_transition.fade_out()
