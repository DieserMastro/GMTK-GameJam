class_name KitchenTableMiniGame
extends MiniGame

signal mixture_ready
signal cake_complete

enum STATE {
	MIXTURE_PHASE,
	GARNISH_PHASE,
}

var _ingredients_needed := 4

@onready var mixture_phase: Node2D = $MixturePhase
@onready var garnish_phase: Node2D = $GarnishPhase
@onready var mixture: Clickable = $MixturePhase/Mixture


func _ready() -> void:
	super()
	_ingredients_needed = mixture_phase.find_children("*", "Draggable").size()


func _unhandled_key_input(event: InputEvent) -> void:
	if _can_exit_manually and event.is_action_pressed("interact"):
		_end()


func spawn(state: STATE) -> void:
	match state:
		STATE.MIXTURE_PHASE:
			mixture.enabled = false
			garnish_phase.queue_free()
		STATE.GARNISH_PHASE:
			mixture_phase.queue_free()
		_:
			push_error("Kitchen table mini game state doesn't exist %s" % state)


func _exit() -> void:
	super()
	queue_free()


func _on_mixture_completed() -> void:
	mixture_ready.emit()
	_end()


func _on_ingredient_dropped_into_drop_zone(draggable: Draggable) -> void:
	draggable.queue_free()
	_ingredients_needed -= 1

	if _ingredients_needed <= 0:
		mixture.enabled = true


func _on_garnish_dropped_into_drop_zone(draggable: Draggable) -> void:
	draggable.queue_free()
	cake_complete.emit()
	_end()
