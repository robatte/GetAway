extends VehicleBody3D

const MAX_STEER_ANGLE = 0.35
const STEER_SPEED = 1

const MAX_ENGINE_FORCE = 175
const MAX_BREAK_FORCE = 10
const MAX_SPEED = 30

var steer_target = 0.0
var steer_angle = 0.0

var money = 0
const money_drop = 50 
const beacon_money = 1000
var players = {}
var player_data = {"steer": 0, "engine": 0, "brakes": 0, 
					"position": null, "speed": 0, "money": 0}

@onready var debug_overlay_list = $Gui/DebugItemList

func _ready():
	debug_overlay_list.hide()
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
		$Arrow.queue_free()
		
func _input(ev):
	if ev.is_action_released("console") and debug_overlay_list:
		debug_overlay_list.visible = !debug_overlay_list.visible
	elif ev.is_action_released("debug"):
		var prop_nodes = get_tree().get_nodes_in_group("prop")
		for prop in prop_nodes:
			Helper.activate_collision(prop)
		
func _physics_process(delta):
	if debug_overlay_list != null and debug_overlay_list.visible:
		debug_overlay_list.clear()
		debug_overlay_list.add_item("fps: " + str(Performance.get_monitor(Performance.TIME_FPS)), null, false)
		debug_overlay_list.add_item("id: " + str(Network.local_player_id), null, false)
		debug_overlay_list.add_item("isServer: " + str(Network.local_player_id == 1), null, false)
		debug_overlay_list.add_item("isLocal: " + str(is_local_Player()), null, false)
	
	if is_local_Player():
		drive(delta)
		display_location()
	if not Network.local_player_id == 1:
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

@rpc("authority", "call_local", "unreliable")
func update_players(player_infos):
	players = player_infos

func update_server(id, steering_value, throttle, brakes, speed):
	if not Network.local_player_id == 1:
		rpc_id(1, "manage_clients", id, steering_value, throttle, brakes, speed)
	else:
		manage_clients(id, steering_value, throttle, brakes, speed)
	get_tree().call_group("Interface", "update_speed", speed)
	
@rpc("any_peer", "call_remote")
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

func beacon_emptied():
	money += beacon_money
	manage_money()
	
func manage_money():	
	if Network.local_player_id == 1:
		update_money(name, money)
	else: 
		rpc_id(1, "update_money", name, money)

@rpc("any_peer", "call_local", "reliable")
func update_money(id, cash):
	players[id].money = cash
	if is_local_Player():
		display_money(cash)
	else:
		rpc_id(int(str(id)), "display_money", cash)
	
@rpc("any_peer", "call_local", "reliable")
func display_money(cash):
	money = players[name].money
	$Gui/MarginContainer/ColorRect/VBoxContainer/MoneyLabel/AnimationPlayer.play("MoneyPulse")
	$Gui/MarginContainer/ColorRect/VBoxContainer/MoneyLabel.text = "§ " + str(cash)

func money_delivered():
	get_tree().call_group("Announcements", "money_stashed", Save.save_data["Player_name"], money)
	money = 0
	manage_money()
	
func _on_body_entered(body: Node) -> void:
	if body.has_node("Money"):
		body.queue_free()
		money += money_drop
		manage_money()
	elif money > 0 and not is_in_group("cops"):
		spawn_money()
		money -= money_drop
		if money < 0:
			money = 0
		manage_money()

@rpc("any_peer","call_local", "reliable")
func spawn_money():
	var moneybag = preload("res://Props/MoneyBag/MoneyBag.tscn").instantiate()
	moneybag.translate(Vector3(position.x, 5, position.z))
	get_parent().get_parent().add_child(moneybag)
	

