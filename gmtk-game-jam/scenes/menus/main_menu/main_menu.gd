extends Control


func _on_play_button_pressed() -> void:
	AudioManager.play_sfx(AudioManager.SFX.UI_PRESSED)
	GameManager.reset_run()
	GameManager.main.load_scene(Main.SCENE.TOWN_SQUARE)


func _on_play_button_mouse_entered() -> void:
	AudioManager.play_sfx(AudioManager.SFX.UI_HOVER)
