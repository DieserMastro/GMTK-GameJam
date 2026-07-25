class_name ClickableComponent
extends Area2D

signal clicked


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is not InputEventMouseButton or event.button_index != MOUSE_BUTTON_LEFT:
		return

	if event.is_pressed():
		clicked.emit()
