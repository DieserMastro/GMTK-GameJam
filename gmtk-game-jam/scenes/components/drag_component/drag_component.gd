class_name DragComponent
extends Area2D

signal drag_started
signal drag_ended

@export var enabled := true

var _can_drag := false
var _is_dragging := false


func _unhandled_input(event: InputEvent) -> void:
	if not _is_dragging or event is not InputEventMouseButton:
		return

	if event.button_index == MOUSE_BUTTON_LEFT and event.is_released():
		drag_ended.emit()
		_is_dragging = false


func is_dragging() -> bool:
	return _is_dragging


func _on_mouse_entered() -> void:
	_can_drag = true


func _on_mouse_exited() -> void:
	_can_drag = false


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is not InputEventMouseButton or event.button_index != MOUSE_BUTTON_LEFT:
		return

	if _can_drag and event.is_pressed():
		drag_started.emit()
		_is_dragging = true
