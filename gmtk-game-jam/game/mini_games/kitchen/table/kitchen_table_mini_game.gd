class_name KitchenTableMiniGame
extends MiniGame

signal mixture_ready
signal cake_complete

@onready var mixture_phase: Node2D = $MixturePhase
@onready var garnish_phase: Node2D = $GarnishPhase
@onready var mixture: Clickable = $MixturePhase/Mixture
@onready var egg: Draggable = $MixturePhase/Egg
@onready var cake: Node2D = $GarnishPhase/Cake
@onready var garnish: Draggable = $GarnishPhase/Garnish


func _unhandled_key_input(event: InputEvent) -> void:
	if _can_exit_manually and event.is_action_pressed("interact"):
		_end()


func spawn(data: Dictionary[String, bool]) -> void:
	if data.get("mixture_ready"):
		print("Mixture ready, time for cake and garnish")
		mixture_phase.queue_free()
		return

	print("Mixture not ready, time for egg and mix")
	mixture.enabled = false
	garnish_phase.queue_free()


func _exit() -> void:
	super()
	queue_free()


func _on_mixture_completed() -> void:
	print("Mixture ready, exiting to kitchen")
	mixture_ready.emit()
	_end()


func _on_egg_dropped_into_drop_zone() -> void:
	print("Egg added, enabling mixture")
	egg.queue_free()
	mixture.enabled = true


func _on_garnish_dropped_into_drop_zone() -> void:
	print("Garnish put on cake, exiting to kitchen")
	cake_complete.emit()
	_end()
