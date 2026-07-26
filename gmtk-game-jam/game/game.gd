class_name Game
extends Node2D

@export var should_limit_camera := true

@onready var fade_transition: FadeTransition = $FadeTransition
@onready var hud: HUD = $HUD
@onready var world: TileMapLayer = $TileMapLayer
@onready var player: Player = $Player
@onready var camera: Camera2D = $Player/Camera2D


func _ready() -> void:
	fade_transition.fade_in_finished.connect(_on_fade_in_transition_finished)
	fade_transition.fade_out_finished.connect(_on_fade_out_transition_finished)
	GameManager.run_over.connect(_stop_timers)
	GameManager.time_expired.connect(_on_time_expired)
	player.teleported.connect(camera.reset_smoothing)

	_restrict_camera()


func _start() -> void:
	pass


func _end() -> void:
	pass


func _exit() -> void:
	get_tree().reload_current_scene()


func toggle_pause() -> void:
	if GameManager.is_showing_outcome:
		return

	var is_paused := get_tree().paused

	if is_paused:
		hud.unpause()
		GameManager.pause_game_timer(false)
	else:
		hud.pause()
		GameManager.pause_game_timer(true)

	get_tree().paused = not get_tree().paused


func _restrict_camera() -> void:
	if not world.tile_set or not should_limit_camera:
		return

	var level_size := world.get_used_rect()

	if level_size.get_area() == 0:
		return

	var tile_size := world.tile_set.tile_size
	camera.limit_left = level_size.position.x * tile_size.x
	camera.limit_right = level_size.end.x * tile_size.x
	camera.limit_top = level_size.position.y * tile_size.y
	camera.limit_bottom = level_size.end.y * tile_size.y


func _on_fade_in_transition_finished() -> void:
	_start()


func _on_fade_out_transition_finished() -> void:
	if GameManager.is_run_over():
		GameManager.show_outcome()
		return

	_exit()


func _on_time_expired() -> void:
	_end()


func _stop_timers() -> void:
	for timer: Timer in find_children("*", "Timer", true, false):
		timer.stop()
