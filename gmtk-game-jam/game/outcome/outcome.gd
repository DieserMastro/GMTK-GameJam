extends Control

const OUTCOME_BAD = preload("uid://csg2o6y6l4hpn")
const OUTCOME_MID = preload("uid://n58vppfb4qwm")
const OUTCOME_WIN = preload("uid://chvq583433wwh")

@export var outcomes: Array[OutcomeResource] = [OUTCOME_BAD, OUTCOME_MID, OUTCOME_WIN]

var _outcome: OutcomeResource

@onready var background: TextureRect = $Background
@onready var title_label: Label = $ContentContainer/VBoxContainer/TitleLabel
@onready var summary_label: Label = $ContentContainer/VBoxContainer/SummaryLabel
@onready var fade_transition: FadeTransition = $FadeTransition


func _ready() -> void:
	_outcome = _earned_outcome()
	_display_outcome()
	fade_transition.fade_in_finished.connect(_on_fade_in_finished)
	fade_transition.fade_out_finished.connect(_on_fade_out_finished)
	fade_transition.fade_in()


func _earned_outcome() -> OutcomeResource:
	for index in range(outcomes.size() - 1, -1, -1):
		if outcomes[index].is_earned(GameManager.supplies, GameManager.money):
			return outcomes[index]

	return outcomes[0]


func _display_outcome() -> void:
	summary_label.text = "Supplies: %d\nMoney: %d" % [GameManager.supplies, GameManager.money]

	if not _outcome:
		title_label.text = "The festival ends"
		return

	title_label.text = _outcome.title
	background.texture = _outcome.background


func _on_fade_in_finished() -> void:
	if not _outcome or not _outcome.dialogue:
		return

	DialogueManager.dialogue_completed.connect(_leave)
	DialogueManager.start_dialogue(_outcome.dialogue, _outcome.speaker_name)


func _leave() -> void:
	fade_transition.fade_out()


func _on_fade_out_finished() -> void:
	GameManager.main.load_scene(Main.SCENE.MAIN_MENU)
