extends Control


func _on_play_button_pressed() -> void:
	GameManager.main.load_scene(Main.SCENE.TOWN_SQUARE)
