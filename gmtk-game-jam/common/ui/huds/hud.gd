class_name HUD
extends CanvasLayer

@export var title := "Town Square"

@onready var time_left_label: Label = $ContentContainer/TimeLeftLabel
@onready var title_label: Label = $ContentContainer/TitleLabel
@onready var pause_container: Control = $PauseContainer


func _init() -> void:
	GameManager.time_left_changed.connect(_on_time_left_changed)


func _ready() -> void:
	title_label.text = title
	if GameManager.time_left:
		_on_time_left_changed(GameManager.time_left)


func pause() -> void:
	pause_container.show()


func unpause() -> void:
	pause_container.hide()


func _on_time_left_changed(time_left: int) -> void:
	time_left_label.text = Util.format_time_to_string(time_left)
