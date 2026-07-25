extends CanvasLayer

const CHARACTER_TIMER := 0.05

signal dialogue_started
signal dialogue_completed


var _current_line_index := 0
var _name: String
var _lines: Array[String]
var _type_tween: Tween

@onready var name_text: Label = %NameText
@onready var dialogue_text: Label = %DialogueText
@onready var dialogue_box: MarginContainer = $DialogueBox



func _ready() -> void:
	_stop_typing()
	dialogue_box.hide()


func start_dialogue(dialogue: DialogueResource, char_name: String) -> void:
	if dialogue.lines.is_empty():
		return

	_name = char_name
	_lines = dialogue.lines
	_current_line_index = 0
	dialogue_box.show()
	dialogue_started.emit()
	_show_line()


func _input(event: InputEvent) -> void:
	if not dialogue_box.visible:
		return

	if not event.is_action_pressed("interact"):
		return
	
	get_viewport().set_input_as_handled()

	if _is_typing():
		_finish_line()
		return

	_advance_dialogue()


func _advance_dialogue() -> void:
	_current_line_index += 1

	if _current_line_index < _lines.size():
		_show_line()
		return

	_end_dialogue()


func _end_dialogue() -> void:
	_stop_typing()
	dialogue_box.hide()
	dialogue_completed.emit()


func _show_line() -> void:
	_stop_typing()
	
	name_text.text = "%s:" % _name
	var line := _lines[_current_line_index]
	dialogue_text.text = line
	dialogue_text.visible_characters = 0

	_type_tween = create_tween()
	_type_tween.tween_property(
		dialogue_text, "visible_characters", line.length(), line.length() * CHARACTER_TIMER
	)


func _finish_line() -> void:
	_stop_typing()
	dialogue_text.visible_characters = -1


func _stop_typing() -> void:
	if _type_tween != null:
		_type_tween.kill()
		_type_tween = null


func _is_typing() -> bool:
	return _type_tween != null and _type_tween.is_running()
