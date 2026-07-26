class_name DialogueInteractionResource
extends InteractionResource

@export_group("Dialogue")
@export var dialogue: DialogueResource
@export var completed_dialogue: DialogueResource
@export var should_go_to_destination := false
@export var dialogue_destination: Main.SCENE
@export_group("Mini Game")
@export var mini_game: Main.SCENE
@export var requires_all_mini_games := false


func interact(interactable: Interactable) -> void:
	var current_dialogue := completed_dialogue if _is_mini_game_finished() else dialogue

	if not current_dialogue or current_dialogue.lines.is_empty():
		return

	if should_go_to_destination and not _is_mini_game_finished():
		DialogueManager.dialogue_completed.connect(_on_dialogue_completed, CONNECT_ONE_SHOT)

	DialogueManager.start_dialogue(current_dialogue, interactable.name)


func is_available() -> bool:
	if completed_dialogue:
		return true

	return not _is_mini_game_finished()


func _is_mini_game_finished() -> bool:
	if requires_all_mini_games:
		return GameManager.are_all_mini_games_finished()

	return GameManager.is_mini_game_finished(mini_game)


func _on_dialogue_completed() -> void:
	GameManager.main.load_scene(dialogue_destination)
