@tool
class_name FadeTransition
extends CanvasLayer

signal fade_in_finished
signal fade_out_finished

const DEFAULT_FADE_IN_DURATION := 1.0
const DEFAULT_FADE_OUT_DURATION := 1.0

@export var fade_in_duration := DEFAULT_FADE_IN_DURATION
@export var fade_out_duration := DEFAULT_FADE_OUT_DURATION

var _tween: Tween

@onready var fade_rect: ColorRect = $FadeRect


func _ready() -> void:
	if Engine.is_editor_hint():
		queue_free()


func fade_in(duration := fade_in_duration) -> void:
	await _fade(0.0, duration)
	fade_in_finished.emit()


func fade_out(duration := fade_out_duration) -> void:
	await _fade(1.0, duration)
	fade_out_finished.emit()


func _fade(alpha: float, duration: float) -> void:
	_kill_tween()

	_tween = create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN_OUT)
	_tween.tween_property(fade_rect, "color:a", alpha, duration)
	await _tween.finished


func _kill_tween() -> void:
	if not _tween or not _tween.is_valid():
		return

	_tween.kill()
