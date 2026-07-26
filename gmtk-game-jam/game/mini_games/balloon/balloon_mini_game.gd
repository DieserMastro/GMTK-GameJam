extends MiniGame

enum STATE {
	INTRO,
	SHOOTING,
	END,
}

const BALLOON_SPAWN_INCREASE_RATIO := 1.05
const BALLOON_INTRO_DIALOGUE = preload("uid://b0gp5mj02xmka")
const BALLOON_END_DIALOGUE = preload("uid://dnr6uqdgy7n3x")
const BALLOON_GUY_NAME := "Balloon guy"
const BALLOON_SCENE = preload("uid://c1hh13qvefpp3")
const CROSSHAIR_TEXTURE = preload("uid://dej0amaqtt46g")

@export_group("Properties")
@export var game_duration := 15.0
@export var balloon_spawn_interval := 0.75
@export var minimum_balloon_money := 5
@export var maximum_balloon_money := 10
@export_group("State")
@export var initial_state := STATE.INTRO

var _state: STATE
var _balloons_popped := 0

@onready var balloon_spawn_timer: Timer = $BalloonSpawnTimer
@onready var game_timer: Timer = $GameTimer
@onready var path_follow_2d: PathFollow2D = $Path2D/PathFollow2D
@onready var balloons: Node2D = $Balloons
@onready var clock: Clock = $Clock


func _ready() -> void:
	super()
	player.queue_free()
	balloon_spawn_timer.wait_time = balloon_spawn_interval
	game_timer.wait_time = game_duration
	clock.follow(game_timer)


func _start() -> void:
	_change_state(initial_state)


func _finish_game() -> void:
	balloon_spawn_timer.stop()
	clock.retract()
	_clear_balloons()
	_complete()
	DialogueManager.start_dialogue(BALLOON_END_DIALOGUE, BALLOON_GUY_NAME)
	DialogueManager.dialogue_completed.connect(_on_dialogue_completed, CONNECT_ONE_SHOT)


func _end() -> void:
	super()
	Input.set_custom_mouse_cursor(null)


func _exit() -> void:
	GameManager.main.load_scene(Main.SCENE.TOWN_SQUARE)


func _change_state(new_state: STATE) -> void:
	match new_state:
		STATE.INTRO:
			DialogueManager.start_dialogue(BALLOON_INTRO_DIALOGUE, BALLOON_GUY_NAME)
			DialogueManager.dialogue_completed.connect(_on_dialogue_completed, CONNECT_ONE_SHOT)
		STATE.SHOOTING:
			_start_game()
		STATE.END:
			_finish_game()

	_state = new_state


func _start_game() -> void:
	Input.set_custom_mouse_cursor(
		CROSSHAIR_TEXTURE,
		Input.CURSOR_ARROW,
		CROSSHAIR_TEXTURE.get_size() / 2.0,
	)
	game_timer.start()
	clock.drop_in()
	_spawn_balloon()


func _spawn_balloon() -> void:
	path_follow_2d.progress_ratio = randf()
	var spawn_position := path_follow_2d.global_position
	var balloon: Balloon = BALLOON_SCENE.instantiate()
	balloon.global_position = spawn_position
	balloon.popped.connect(_on_balloon_popped)
	balloons.add_child(balloon)
	_update_spawn_interval()
	balloon_spawn_timer.start()


func _clear_balloons() -> void:
	for balloon in balloons.get_children():
		balloon.queue_free()


func _update_spawn_interval() -> void:
	var elapsed_ratio := 1.0 - game_timer.time_left / game_timer.wait_time
	var spawn_rate := 1.0 + BALLOON_SPAWN_INCREASE_RATIO * elapsed_ratio
	balloon_spawn_timer.wait_time = balloon_spawn_interval / spawn_rate


func _on_balloon_popped() -> void:
	_balloons_popped += 1
	GameManager.money += randi_range(minimum_balloon_money, maximum_balloon_money)


func _on_balloon_spawn_timer_timeout() -> void:
	_spawn_balloon()


func _on_game_timer_timeout() -> void:
	_change_state(STATE.END)


func _on_dialogue_completed() -> void:
	match _state:
		STATE.INTRO:
			_change_state(STATE.SHOOTING)
		STATE.END:
			_end()
