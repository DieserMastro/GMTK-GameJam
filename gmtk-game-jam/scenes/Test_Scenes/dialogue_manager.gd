class_name DialogueManager
extends CanvasLayer

@onready var dialogue_box: Control = $DialogueBox
@onready var dialogue_text: Label = $DialogueBox/DialogueText
@onready var text_timer: Timer = $DialogueBox/Timer

@export var dialogue_lines: Array[String] = [];
var current_line_index: int = 0;
var is_dialogue_active: bool = false;
var next_char_ready: bool = false;
signal dialogue_completed;

func _ready() -> void:
	dialogue_box.visible = false;
	
func start_dialogue(lines: Array[String]):
	##SET GAME TO PAUSE!!!
	dialogue_lines = lines;
	current_line_index = 0;
	is_dialogue_active = true;
	dialogue_box.visible = true;
	show_line(dialogue_lines[current_line_index]);
	
func _input(event: InputEvent) -> void:
	if not is_dialogue_active:
		return;
	if event.is_action_pressed("interact"):
		advance_dialogue()
		
func advance_dialogue():
	if current_line_index < dialogue_lines.size()-1:
		current_line_index += 1;
		show_line(dialogue_lines[current_line_index]);
	
	else:
		##unpause
		is_dialogue_active = false;
		dialogue_box.visible = false;
		dialogue_completed.emit();
	
func show_line(line: String):
	dialogue_text.text = "";
	for char in line:
		text_timer.start();
		await text_timer.timeout;
		dialogue_text.text += char;
