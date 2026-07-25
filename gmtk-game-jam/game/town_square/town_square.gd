extends Game

@onready var characters: Node2D = $Characters


func _ready() -> void:
	super()
	_spawn_player()
	_update_characters()
	GameManager.start_game_timer()
	fade_transition.fade_in()


func _exit_tree() -> void:
	GameManager.town_square_player_position = player.global_position


func _end() -> void:
	fade_transition.fade_out()


func _spawn_player() -> void:
	if GameManager.town_square_player_position.is_zero_approx():
		return

	player.global_position = GameManager.town_square_player_position


func _update_characters() -> void:
	for character in characters.get_children():
		if character is not Interactable or not character.interaction_resource:
			continue

		character.enabled = character.interaction_resource.is_available()
