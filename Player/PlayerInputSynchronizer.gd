extends MultiplayerSynchronizer

const MAX_STEER_ANGLE = 0.35
const STEER_SPEED = 1

const MAX_ENGINE_FORCE = 175
const MAX_BREAK_FORCE = 10
const MAX_SPEED = 30

var steer_target = 0.0
var steer_angle = 0.0
var engine = 0.0
var steering_value = 0.0
var speed = 0.0

@export var brakes = 0.0

func _ready() -> void:
	# Only process for the local player.
	set_physics_process(get_multiplayer_authority() == multiplayer.get_unique_id())


func _physics_process(delta: float) -> void:
#	var speed = players[name].speed
	steering_value = apply_steering(delta)
	engine = apply_throttle(delta, speed)
	brakes = apply_brakes(delta)

func apply_steering(delta):

	var steer_val = 0
	var left = Input.get_action_strength("steer_left")
	var right = Input.get_action_strength("steer_right")

	if left:
		steer_val = left
	elif right:
		steer_val = -right

	steer_target = steer_val * MAX_STEER_ANGLE

	if steer_target < steer_angle:
		steer_angle -= STEER_SPEED * delta
	elif steer_target > steer_angle:
		steer_angle += STEER_SPEED * delta

	return steer_angle

func apply_throttle(_delta, speed):
	var throttle_val = 0
	var forward = Input.get_action_strength("forward")	
	var backward = Input.get_action_strength("backward")	

	if speed < MAX_SPEED:
		if backward:
			throttle_val = -backward
		elif forward:
			throttle_val = forward

	return throttle_val * MAX_ENGINE_FORCE

func apply_brakes(_delta):
	var brake_val = 0
	var brake_strength = Input.get_action_strength("brake")

	if brake_strength:
		brake_val = brake_strength

	return brake_val * MAX_BREAK_FORCE
