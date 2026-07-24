extends Node2D

signal completed

@export_group("Data")
@export var clickable_resource: ClickableResource

var _clicks_left := 5

@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	if not clickable_resource:
		return

	sprite.texture = clickable_resource.texture
	_clicks_left = clickable_resource.clicks_needed


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if _clicks_left == 0 or not event.is_pressed():
		return

	_clicks_left -= 1
	if _clicks_left > 0:
		return

	if clickable_resource:
		sprite.texture = clickable_resource.texture_when_complete

	completed.emit()


func _on_body_entered(body: Node2D) -> void:
	print(body)
