class_name InteractableResource
extends Resource

@export_group("Texture")
@export var sprite_frames: SpriteFrames
@export_group("Interaction")
@export var interaction_resource: InteractionResource


func can_interact() -> bool:
	return interaction_resource != null
