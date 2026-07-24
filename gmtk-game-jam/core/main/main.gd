class_name Main
extends Node

enum SCENE {
	MAIN_MENU,
	TOWN_SQUARE,
	KITCHEN_GAME,
}

@export_group("Scenes")
@export var initial_scene := SCENE.MAIN_MENU

var _current_scene: Node
var _scene_paths: Dictionary[SCENE, String] = {
	SCENE.MAIN_MENU: "uid://can2dbsfqk2ii",
	SCENE.TOWN_SQUARE: "uid://b170u02mew26o",
	SCENE.KITCHEN_GAME: "uid://dxvlmr187anxi",
}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.main = self
	load_scene(initial_scene)


func unload_scene() -> void:
	if not _current_scene:
		return

	_current_scene.queue_free()
	_current_scene = null


func load_scene(new_scene: SCENE) -> void:
	unload_scene()

	var scene := load(_scene_paths[new_scene])
	_current_scene = scene.instantiate()
	add_child.call_deferred(_current_scene)
