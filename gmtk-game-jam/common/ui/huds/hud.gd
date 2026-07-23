extends CanvasLayer

@export var title := "Town Square"

@onready var time_left_label: Label = $MarginContainer/TimeLeftLabel
@onready var title_label: Label = $MarginContainer/TitleLabel


func _init() -> void:
	GameManager.time_left_changed.connect(_on_time_left_changed)


func _ready() -> void:
	_on_time_left_changed(GameManager.time_left)
	title_label.text = title


func _on_time_left_changed(time_left: int) -> void:
	time_left_label.text = Util.format_time_to_string(time_left)
