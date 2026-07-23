extends CanvasLayer

@onready var time_left_label: Label = $TimeLeftLabel


func _init() -> void:
	GameManager.time_left_changed.connect(_on_time_left_changed)


func _ready() -> void:
	_on_time_left_changed(GameManager.time_left)


func _on_time_left_changed(time_left: int) -> void:
	time_left_label.text = Util.format_time_to_string(time_left)
