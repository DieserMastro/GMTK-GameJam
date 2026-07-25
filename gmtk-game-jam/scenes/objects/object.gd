@tool
class_name GameObject
extends Node2D

@export var object_resource: ObjectResource

@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	if not object_resource:
		return

	sprite.texture = object_resource.texture
	normal()


func small() -> void:
	if not object_resource:
		return

	sprite.scale = Vector2.ONE * object_resource.small_texture_scale


func normal() -> void:
	if not object_resource:
		return

	sprite.scale = Vector2.ONE * object_resource.standard_texture_scale
