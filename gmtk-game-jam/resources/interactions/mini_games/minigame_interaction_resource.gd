class_name MiniGameInteractionResource
extends InteractionResource

@export var mini_game: Main.SCENE


func interact(_interactable: Interactable) -> void:
	if not GameManager.main:
		return

	GameManager.main.load_scene(mini_game)
