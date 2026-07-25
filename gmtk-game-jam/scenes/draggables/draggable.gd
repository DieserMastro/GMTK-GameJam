@tool
class_name Draggable
extends AnimatableBody2D

signal dropped_into_drop_zone(draggable: Draggable)

const DRAGGABLE_OUTLINE_MATERIAL := preload("uid://ybaumnfu1sk4")
const OUTLINE_THICKNESS := 2.0
const UNAVAILABLE_MODULATE := Color(0.5, 0.5, 0.5, 0.6)

@export_group("Data")
@export var draggable_resource: DraggableResource

@export_group("Properties")
@export_range(50, 200) var drag_weight := 75.0
@export var can_drag: bool = true:
	set(value):
		can_drag = value
		_update_appearance()

var _can_follow := false
var _drop_zone: DropZoneComponent
var _is_hovered := false

@onready var sprite: Sprite2D = $Sprite2D
@onready var drag_component: DragComponent = $DragComponent


func _ready() -> void:
	drag_component.mouse_entered.connect(_on_drag_component_mouse_entered)
	drag_component.mouse_exited.connect(_on_drag_component_mouse_exited)

	if draggable_resource:
		sprite.texture = draggable_resource.texture
		sprite.scale = Vector2.ONE * draggable_resource.texture_scale

	_update_appearance()


func _physics_process(delta: float) -> void:
	if not _can_follow:
		return

	var mouse_position := get_global_mouse_position()
	var weight := 1 - exp(-drag_weight * delta)
	global_position = global_position.lerp(mouse_position, weight)


func set_drop_zone(drop_zone: DropZoneComponent) -> void:
	_drop_zone = drop_zone


func unset_drop_zone() -> void:
	_drop_zone = null


func _on_drag_component_mouse_entered() -> void:
	_is_hovered = true
	_update_appearance()


func _on_drag_component_mouse_exited() -> void:
	_is_hovered = false
	_update_appearance()


func _on_drag_component_drag_started() -> void:
	_can_follow = true


func _on_drag_component_drag_ended() -> void:
	_can_follow = false
	if _drop_zone:
		dropped_into_drop_zone.emit(self)


func _update_appearance() -> void:
	if not is_node_ready():
		return

	drag_component.enabled = can_drag
	modulate = Color.WHITE if can_drag else UNAVAILABLE_MODULATE
	sprite.material = DRAGGABLE_OUTLINE_MATERIAL if can_drag and _is_hovered else null
