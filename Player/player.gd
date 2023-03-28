extends VehicleBody3D

const MAX_STEER_ANGLE = 0.35
const STEER_SPEED = 1

const MAX_ENGINE_FORCE = 175
const MAX_BREAK_FORCE = 10
const MAX_SPEED = 30

var steer_target = 0.0
var steer_angle = 0.0

var players = {}
var player_data = {"steer": 0, "engine": 0, "brakes": 0, "position": null, "speed": 0}

func _ready():
	join_team()
	players[name] = player_data
	players[name].position = transform
	
	if not is_local_Player():
		$SmoothCamera.queue_free()
		$Gui.queue_free()
	
func is_local_Player():
	return name == str(Network.local_player_id)

func join_team():
	if Network.players[int(str(name))]["is_cop"]:
		add_to_group("cops")
		collision_layer = 4
		$RobberMesh.queue_free()
	else:
		$PoliceMesh.queue_free()
		

func _physics_process(delta):
	if is_local_Player():
		drive(delta)
		display_location()
	if not multiplayer.is_server():
		transform = players[name].position
		
	steering = players[name].steer
	engine_force = players[name].engine
	brake = players[name].brakes
	
func drive(delta):
	var speed = players[name].speed
	var steering_value = apply_steering(delta)
	var throttle = apply_throttle(delta, speed)
	var brakes = apply_brakes(delta)
	
	update_server(name, steering_value, throttle, brakes, speed)
	
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

@rpc("unreliable")
func update_players(player_infos):
	players = player_infos

func update_server(id, steering_value, throttle, brakes, speed):
	if not multiplayer.is_server():
		rpc("manage_clients", id, steering_value, throttle, brakes, speed)
	else:
		manage_clients(id, steering_value, throttle, brakes, speed)
	get_tree().call_group("Interface", "update_speed", speed)
	
@rpc("any_peer", "unreliable")
func manage_clients(id, steering_value, throttle, brakes, speed):
	players[id].steer = steering_value
	players[id].engine = throttle
	players[id].brakes = brakes
	players[id].position = transform
	players[id].speed = linear_velocity.length()
	rpc("update_players", players)

func display_location():
	var x = snapped(position.x, 1)
	var z = snapped(position.z, 1)
	
	$Gui/MarginContainer/ColorRect/VBoxContainer/Location.text = str(x) + ", " + str(z)
