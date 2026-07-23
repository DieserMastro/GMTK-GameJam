extends StaticBody2D

@onready var interactive_component: InteractiveComponent = $InteractiveComponent


func _physics_process(_delta: float) -> void:
	var player := get_tree().get_first_node_in_group("player")
	look_at(player.global_position)


func _on_interactive_component_interacted() -> void:
	# TODO: Start dialogue
	GameManager.main.load_scene(Main.SCENE.MINI_GAME)
