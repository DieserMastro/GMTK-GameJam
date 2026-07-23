extends Node


func format_time_to_string(time: int) -> String:
	@warning_ignore("integer_division") var minutes := floori(time / 60)
	var seconds := floori(time - (minutes * 60))

	return "%02d:%02d" % [minutes, seconds]
