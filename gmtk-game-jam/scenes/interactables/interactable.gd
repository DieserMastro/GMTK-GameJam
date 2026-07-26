@tool
class_name Interactable
extends StaticBody2D

signal interacted

const INTERACTABLE_OUTLINE = preload("uid://cpjmjky3ccwkf")

@export_group("Data")
@export var interactable_resource: InteractableResource
@export var interaction_resource: InteractionResource
@export_group("Properties")
@export var enabled: bool = true:
	set(value):
		enabled = value
		_update_outline()

var _is_player_in_range := false

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	_update_outline()

	if not interactable_resource:
		return

	sprite.sprite_frames = interactable_resource.sprite_frames
	if not interactable_resource.play_only_on_interaction:
		sprite.play("default")


func enable() -> void:
	enabled = true


func disable() -> void:
	enabled = false


func set_resource(new_resource: InteractableResource) -> void:
	interactable_resource = new_resource
	sprite.sprite_frames = new_resource.sprite_frames

	if sprite.sprite_frames and not new_resource.play_only_on_interaction:
		sprite.play("default")


func _on_interactive_component_interacted() -> void:
	if not enabled or not interactable_resource:
		return

	AudioManager.play_sfx(AudioManager.SFX.INTERACTION)

	if interactable_resource.play_only_on_interaction:
		sprite.play("default")

	if interaction_resource:
		interaction_resource.interact(self)

	interacted.emit()


func _on_interactive_component_body_entered(_body: Node2D) -> void:
	_is_player_in_range = true
	_update_outline()


func _on_interactive_component_body_exited(_body: Node2D) -> void:
	_is_player_in_range = false
	_update_outline()


func _update_outline() -> void:
	if not is_node_ready():
		return

	sprite.material = INTERACTABLE_OUTLINE if enabled and _is_player_in_range else null
