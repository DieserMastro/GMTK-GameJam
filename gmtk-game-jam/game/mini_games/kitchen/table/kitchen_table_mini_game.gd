class_name KitchenTableMiniGame
extends MiniGame

signal mixture_ready
signal cake_complete

enum STATE {
	MIXTURE_PHASE,
	GARNISH_PHASE,
}

var _draggables: Array[Draggable] = []
var _state: STATE

@onready var mixture_phase: Node2D = $MixturePhase
@onready var garnish_phase: Node2D = $GarnishPhase
@onready var mixture: Clickable = $MixturePhase/Mixture
@onready var cake: Clickable = $GarnishPhase/Cake


func _ready() -> void:
	super()
	mixture.enabled = false
	_collect_draggables(mixture_phase)
	player.queue_free()


func _unhandled_key_input(event: InputEvent) -> void:
	if _can_exit_manually and event.is_action_pressed("interact"):
		_end()


func spawn(state: STATE) -> void:
	_state = state

	match state:
		STATE.MIXTURE_PHASE:
			mixture.enabled = false
			garnish_phase.queue_free()
			_collect_draggables(mixture_phase)
		STATE.GARNISH_PHASE:
			mixture_phase.queue_free()
			_collect_draggables(garnish_phase)
		_:
			push_error("Kitchen table mini game state doesn't exist %s" % state)


func _exit() -> void:
	super()
	queue_free()


func _on_mixture_completed() -> void:
	mixture_ready.emit()
	_end()


func _on_draggable_dropped_into_drop_zone(draggable: Draggable) -> void:
	_draggables.erase(draggable)
	draggable.queue_free()

	if _state == STATE.MIXTURE_PHASE:
		mixture.next_frame()

	if _state == STATE.GARNISH_PHASE:
		cake.next_frame()

	if _draggables.is_empty():
		_on_phase_completed()
		return

	_update_draggable_availability()


func _on_phase_completed() -> void:
	match _state:
		STATE.MIXTURE_PHASE:
			mixture.enabled = true
		STATE.GARNISH_PHASE:
			cake_complete.emit()
			_end()


func _collect_draggables(phase: Node2D) -> void:
	_draggables.assign(phase.find_children("*", "Draggable"))
	_update_draggable_availability()


func _update_draggable_availability() -> void:
	for index in _draggables.size():
		_draggables[index].can_drag = index == 0
