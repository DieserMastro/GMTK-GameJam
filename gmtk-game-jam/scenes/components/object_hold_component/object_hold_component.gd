class_name ObjectHoldComponent
extends Node2D

@export_group("Data")
@export var object_resource: ObjectResource

@onready var sprite: Sprite2D = $Sprite2D
@onready var label: Label = $Label


func _ready() -> void:
	if not object_resource:
		return

	spawn(object_resource)


func spawn(new_resource: ObjectResource) -> void:
	sprite.texture = new_resource.texture
	sprite.scale = Vector2.ONE * new_resource.small_texture_scale


func drop() -> void:
	sprite.texture = null
