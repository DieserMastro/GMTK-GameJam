class_name OutcomeResource
extends Resource

@export var title := "Outcome"
@export_group("Requirements")
@export var minimum_supplies := 0.0
@export var minimum_money := 0.0
@export_group("Presentation")
@export var dialogue: DialogueResource
@export var speaker_name := "Mayor"
@export var crowd_count := 0


func is_earned(supplies: float, money: float) -> bool:
	return supplies >= minimum_supplies and money >= minimum_money
