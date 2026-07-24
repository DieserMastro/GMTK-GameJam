class_name ObjectHoldComponent
extends Node2D

@export_group("Data")
@export var object_resource: ObjectResource

@onready var sprite: Sprite2D = $Sprite2D
@onready var label: Label = $Label


func _ready() -> void:
	if not object_resource:
		return

	sprite.texture = object_resource.texture
	label.text = object_resource.name


func spawn(new_resource: ObjectResource) -> void:
	sprite.texture = new_resource.texture
	label.text = new_resource.name


func drop() -> void:
	sprite.texture = null
	label.text = ""
