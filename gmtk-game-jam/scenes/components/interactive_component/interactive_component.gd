class_name InteractiveComponent
extends Area2D

signal interacted


func interact() -> void:
	interacted.emit()


func _on_body_entered(body: Player) -> void:
	print("Setting interactive")
	body.set_interactive(self)


func _on_body_exited(body: Node2D) -> void:
	print("Unsetting interactive")
	body.unset_interactive()
