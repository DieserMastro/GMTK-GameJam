class_name DropZoneComponent
extends Area2D

const DROP_ZONE_OUTLINE_MATERIAL := preload("uid://0pbxicwpy1fr")

@export_group("Properties")
@export var enabled := true
@export var sprite_to_outline: Sprite2D


func _on_body_entered(body: Draggable) -> void:
	if not enabled:
		return

	body.set_drop_zone(self)

	if sprite_to_outline:
		sprite_to_outline.material = DROP_ZONE_OUTLINE_MATERIAL


func _on_body_exited(body: Node2D) -> void:
	if not enabled:
		return

	body.unset_drop_zone()

	if sprite_to_outline:
		sprite_to_outline.material = null
