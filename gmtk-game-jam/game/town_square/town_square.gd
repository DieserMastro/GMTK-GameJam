extends Game


func _ready() -> void:
	super()
	GameManager.start_game_timer()
	fade_transition.fade_in()


func _end() -> void:
	fade_transition.fade_out()
