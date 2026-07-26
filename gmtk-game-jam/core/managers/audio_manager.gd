extends Node

enum SFX {
	INTERACTION,
	OVEN_ALARM,
	FESTIVAL_START,
	BALLOON_POP,
	CHICKEN,
	UI_HOVER,
	UI_PRESSED,
}

var sfx_paths := {
	SFX.INTERACTION: "uid://bb1cxndg17obt",
	SFX.OVEN_ALARM: "uid://bt587ptyi8i0c",
	SFX.FESTIVAL_START: "uid://chig1p81htku1",
	SFX.BALLOON_POP: "uid://ck482aru3daci",
	SFX.CHICKEN: "uid://dlhx6207o83ht",
	SFX.UI_HOVER: "uid://oq7is82ui5yh",
	SFX.UI_PRESSED: "uid://b0g4eacsek7ft",
}


func play_sfx(sfx_name: SFX, with_pitch := true) -> void:
	var player := AudioStreamPlayer.new()
	player.bus = "SFX"
	player.stream = load(sfx_paths[sfx_name])
	player.pitch_scale = randf_range(0.9, 1.1) if with_pitch else 1.0
	player.finished.connect(_on_player_finished.bind(player))
	add_child.call_deferred(player)
	player.play.call_deferred()


func _on_player_finished(player: AudioStreamPlayer) -> void:
	player.queue_free()
