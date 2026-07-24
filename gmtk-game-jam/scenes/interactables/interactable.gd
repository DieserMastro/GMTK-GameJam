@tool
class_name Interactable
extends StaticBody2D

signal interacted

@export_group("Data")
@export var interactable_resource: InteractableResource
@export_group("Properties")
@export var enabled := true

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	sprite.texture = interactable_resource.texture
	collision_shape_2d.shape = interactable_resource.collision_shape


func _on_interactive_component_interacted() -> void:
	if not enabled:
		return

	if interactable_resource.can_interact():
		interactable_resource.interaction_resource.interact(self)

	interacted.emit()
