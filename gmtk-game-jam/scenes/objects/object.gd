@tool
extends Node2D

@export var object_resource: ObjectResource

@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	sprite.texture = object_resource.texture
