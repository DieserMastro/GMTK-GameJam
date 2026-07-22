extends CharacterBody2D


const SPEED = 300.0;
const RUNSPEED = 200.0;
var interactionRange: Area2D;
var moveVec: Vector2 = Vector2(0,0);
var isRunning: bool = false;
var canInteract: bool = false;

func _ready():
	interactionRange = $interactionRange;

func _physics_process(delta: float):
	movement(delta);
	
func movement(delta):
	if Input.is_action_pressed("up"):
		moveVec.y = -1;
	if Input.is_action_pressed("down"):
		moveVec.y = 1;
	if Input.is_action_pressed("left"):
		moveVec.x = -1;
	if Input.is_action_pressed("right"):
		moveVec.x = 1;
	if Input.is_action_pressed("run"):
		isRunning = true;
	else:
		isRunning = false;
	
	if !Input.is_action_pressed("down") and !Input.is_action_pressed("up"):
		moveVec.y = 0;
	if !Input.is_action_pressed("left") and !Input.is_action_pressed("right"):
		moveVec.x = 0;
	move_and_collide(moveVec.normalized() * (SPEED + (RUNSPEED * int(isRunning))) * delta);
