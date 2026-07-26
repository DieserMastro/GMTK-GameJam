class_name Clock
extends Node2D

const SLIDE_DURATION := 0.6

@export_group("Properties")
@export var starts_hidden := false
@export var hidden_offset := Vector2(0, -64)

var _timer: Timer
var _resting_position: Vector2
var _displayed_seconds := -1
var _slide_tween: Tween

@onready var time: Label = $Time


func _ready() -> void:
	_resting_position = position

	if starts_hidden:
		position = _hidden_position()


func _process(_delta: float) -> void:
	if not _timer or _timer.is_stopped():
		return

	set_time(ceili(_timer.time_left))


func follow(timer: Timer) -> void:
	_timer = timer
	timer.timeout.connect(_on_timer_timeout)
	set_time(ceili(timer.wait_time))


func set_time(seconds: int) -> void:
	if seconds == _displayed_seconds:
		return

	_displayed_seconds = seconds
	time.text = str(seconds)


func drop_in() -> void:
	_slide_to(_resting_position, Tween.TRANS_BACK, Tween.EASE_OUT)


func retract() -> void:
	_slide_to(_hidden_position(), Tween.TRANS_CUBIC, Tween.EASE_IN)


func _hidden_position() -> Vector2:
	return _resting_position + hidden_offset


func _slide_to(target: Vector2, trans: Tween.TransitionType, ease_type: Tween.EaseType) -> void:
	if _slide_tween:
		_slide_tween.kill()

	_slide_tween = create_tween().set_trans(trans).set_ease(ease_type)
	_slide_tween.tween_property(self, "position", target, SLIDE_DURATION)


func _on_timer_timeout() -> void:
	set_time(0)
