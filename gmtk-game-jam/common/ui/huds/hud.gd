class_name HUD
extends CanvasLayer

@export var title := "Town Square"

@onready var time_left_label: Label = $ContentContainer/StatusContainer/TimeLeftLabel
@onready var supplies_label: Label = $ContentContainer/StatusContainer/SuppliesContainer/SuppliesLabel
@onready var money_label: Label = $ContentContainer/StatusContainer/MoneyContainer/MoneyLabel
@onready var title_label: Label = $ContentContainer/TitleLabel
@onready var pause_container: Control = $PauseLayer/PauseContainer


func _init() -> void:
	GameManager.time_left_changed.connect(_on_time_left_changed)


func _ready() -> void:
	title_label.text = title

	GameManager.supplies_changed.connect(_on_supplies_changed)
	GameManager.money_changed.connect(_on_money_changed)
	_on_supplies_changed(GameManager.supplies)
	_on_money_changed(GameManager.money)

	if GameManager.time_left:
		_on_time_left_changed(GameManager.time_left)


func pause() -> void:
	pause_container.show()


func unpause() -> void:
	pause_container.hide()


func _on_time_left_changed(time_left: int) -> void:
	time_left_label.text = Util.format_time_to_string(time_left)


func _on_supplies_changed(supplies: float) -> void:
	supplies_label.text = "%d" % supplies


func _on_money_changed(money: float) -> void:
	money_label.text = "%d" % money
