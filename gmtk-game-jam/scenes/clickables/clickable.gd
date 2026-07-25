@tool
class_name Clickable
extends Node2D

signal completed

const BREATHE_DURATION := 0.25

@export_group("Data")
@export var clickable_resource: ClickableResource
@export_group("Properties")
@export var enabled := true

var _is_complete := false

@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	sprite.frame = 0

	if clickable_resource:
		sprite.texture = clickable_resource.texture
		sprite.hframes = clickable_resource.texture_h_frames


func next_frame() -> void:
	if _is_complete:
		return

	var last_frame := sprite.hframes * sprite.vframes - 1
	sprite.frame = mini(sprite.frame + 1, last_frame)

	if sprite.frame < last_frame:
		return

	_is_complete = true
	completed.emit()


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if not enabled or _is_complete:
		return

	if event is not InputEventMouseButton or event.button_index != MOUSE_BUTTON_LEFT:
		return

	if event.is_pressed():
		next_frame()
