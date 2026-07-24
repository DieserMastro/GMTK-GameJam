class_name InteractableResource
extends Resource

@export var texture: Texture2D
@export var collision_shape: Shape2D
@export var interaction_resource: InteractionResource


func can_interact() -> bool:
	return interaction_resource != null
