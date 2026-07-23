extends StaticBody2D

@onready var interactive_component: InteractiveComponent = $InteractiveComponent


func _on_interactive_component_interacted() -> void:
	# TODO: Start dialogue
	GameManager.main.load_scene(Main.SCENE.MINI_GAME)
