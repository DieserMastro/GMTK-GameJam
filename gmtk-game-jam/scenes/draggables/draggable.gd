@tool
class_name Draggable
extends AnimatableBody2D

signal dropped_into_drop_zone

const DRAGGABLE_OUTLINE_MATERIAL := preload("uid://ybaumnfu1sk4")
const OUTLINE_THICKNESS := 2.0

@export_group("Data")
@export var draggable_resource: DraggableResource

@export_group("Properties")
@export_range(50, 200) var drag_weight := 75.0

var _can_follow := false
var _drop_zone: DropZoneComponent

@onready var sprite: Sprite2D = $Sprite2D
@onready var drag_component: DragComponent = $DragComponent


func _ready() -> void:
	drag_component.mouse_entered.connect(_on_drag_component_mouse_entered)
	drag_component.mouse_exited.connect(_on_drag_component_mouse_exited)

	if draggable_resource:
		sprite.texture = draggable_resource.texture


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
	sprite.material = DRAGGABLE_OUTLINE_MATERIAL


func _on_drag_component_mouse_exited() -> void:
	sprite.material = null


func _on_drag_component_drag_started() -> void:
	_can_follow = true


func _on_drag_component_drag_ended() -> void:
	_can_follow = false
	if _drop_zone:
		dropped_into_drop_zone.emit()
