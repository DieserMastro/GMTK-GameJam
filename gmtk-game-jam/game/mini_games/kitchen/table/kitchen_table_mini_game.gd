extends MiniGame


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		_end()


func _exit() -> void:
	super()
	queue_free()


func _on_mixture_completed() -> void:
	print("mixture completed!")
