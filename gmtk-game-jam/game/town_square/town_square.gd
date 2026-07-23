extends Game


func _init() -> void:
	GameManager.time_expired.connect(_on_time_expired)


func _ready() -> void:
	super()
	GameManager.start_game_timer()
	fade_transition.fade_in()


func _end() -> void:
	fade_transition.fade_out()


func _exit() -> void:
	GameManager.reset_game_timer()
	GameManager.main.load_scene(Main.SCENE.TOWN_SQUARE)


func _on_time_expired() -> void:
	_end()
