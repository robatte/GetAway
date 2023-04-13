extends VehicleBody3D

const MAX_STEER_ANGLE = 0.35
const STEER_SPEED = 1.0

const MAX_ENGINE_FORCE = 175
const MAX_BREAK_FORCE = 10
const MAX_SPEED = 30

var steer_target = 0.0
var steer_angle = 0.0

var paint_color = Color(1, 1, 0)

var money = 0
const money_drop = 50 
const beacon_money = 1000

@export var max_arrest_value = 750

var arrest_value = 0

var criminal_detected = false

var siren = false
var horn = false

var players = {}
var player_data = {"steer": 0, "engine": 0, "brakes": 0, 
					"position": null, "speed": 0, "money": 0, "siren": false, "horn": false}

func _ready():
	paint_color = Network.players[int(str(name))]["paint_color"]
	join_team()
	label_car()
	paint_car()
	players[name] = player_data
	players[name].position = transform
	if not is_local_Player():
		$Camera.call_deferred("free")
		$Gui/Hud.call_deferred("free")

	Helper.Log("Player", "is ready")


func is_local_Player():
	return name == str(Network.local_player_id)

func label_car():
	if is_local_Player():
		$PlayerBillboard/PlayerLabel3D.call_deferred("free")
	else:
		$PlayerBillboard/PlayerBillboardSubViewport/TextureProgressBar.max_value = max_arrest_value
		$PlayerBillboard/PlayerLabel3D.text = Network.players[int(str(name))]["Player_name"]

func paint_car():
	var paint = StandardMaterial3D.new()
	paint.metallic = 0.75
	paint.metallic_specular = 0.25
	paint.roughness = 0.25
	paint.albedo_color = paint_color
	$CarBody.set_surface_override_material(0, paint)

func join_team():
	if Network.players[int(str(name))]["is_cop"]:
		add_to_group("cops")
		collision_layer = 4
		$RobberMesh.call_deferred("free")
		$AudioStreamPlayer3DHorn.call_deferred("free")
		$PoliceMesh.name = "CarBody"
	else:
		$PoliceMesh.call_deferred("free")
		$Arrow.call_deferred("free")
		$Siren.call_deferred("free")
		$RobberMesh.name = "CarBody"
		
func _input(event):
	if event.is_action_pressed("car_sound") and is_local_Player():
		var sound_type
		var sound_state
		if is_in_group("cops"):
			siren = !siren
			sound_type = "siren"
			sound_state = siren
		else:
			horn = true
			sound_type = "horn"
			sound_state = horn
			
		if not Network.local_player_id == 1:
			rpc_id(1, "toggle_car_sound", name, sound_type, sound_state)
		else:
			toggle_car_sound(name, sound_type, sound_state)
			
func _physics_process(delta):	
	if is_local_Player():
		drive(delta)
		display_location()
	if not Network.local_player_id == 1:
		transform = players[name].position
		
	steering = players[name].steer
	engine_force = players[name].engine
	brake = players[name].brakes
	
	if is_in_group("cops"):
		check_siren()
	else:
		check_horn()
		
	if criminal_detected:
		increment_arrest_value()
	
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

@rpc("authority", "unreliable")
func update_players(player_infos):
	players = player_infos

func update_server(id, steering_value, throttle, brakes, speed):
	if not Network.local_player_id == 1:
		rpc_id(1, "manage_clients", id, steering_value, throttle, brakes, speed)
	else:
		manage_clients(id, steering_value, throttle, brakes, speed)
	get_tree().call_group("Interface", "update_speed", speed)
	$Exhaust.update_particles(speed)
	
@rpc("any_peer", "call_local", "unreliable")
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
	$Gui/Hud/ColorRect/VBoxContainer/Location.text = str(x) + ", " + str(z)

func beacon_emptied():
	Helper.Log("Player", "Beacon emptied. Money: " +str(money) + " += " + str(beacon_money))
	money += beacon_money
	manage_money()
	
func manage_money():	
	if Network.local_player_id == 1:
		update_money(name, money)
	else: 
		rpc_id(1, "update_money", name, money)

@rpc("any_peer", "call_remote", "reliable")
func update_money(id, cash):
	players[id].money = cash
	if is_local_Player():
		display_money(cash)
	else:
		rpc_id(int(str(id)), "display_money", cash)
	
@rpc("any_peer", "reliable")
func display_money(cash):
	money = players[name].money
	$Gui/Hud/ColorRect/VBoxContainer/MoneyLabel/AnimationPlayer.play("MoneyPulse")
	$Gui/Hud/ColorRect/VBoxContainer/MoneyLabel.text = "§ " + str(cash)

func money_delivered():
	print("MoneyDelivered by " + str(Network.local_player_id))
	get_tree().call_group("Announcements", "money_stashed", Save.save_data["Player_name"], money)
	Helper.Log("Player", "will stash " + str(money))
	get_tree().call_group("GameState", "update_gamestate", money, 0)
	money = 0
	manage_money()
	
func _on_body_entered(body: Node) -> void:
	if body.has_node("Money"):
		body.queue_free()
		money += money_drop
		if is_in_group("cops"):
			get_tree().call_group("GameState", "update_gamestate", 0, money)
		manage_money()
	elif money > 0 and not is_in_group("cops"):
		spawn_money()
		money -= money_drop
		manage_money()

#@rpc("any_peer","call_local", "reliable")
func spawn_money():
	var moneybag = preload("res://Props/MoneyBag/MoneyBag.tscn").instantiate()
	moneybag.translate(Vector3(position.x, 5, position.z))
	get_parent().get_parent().add_child(moneybag)

@rpc("any_peer", "reliable")
func toggle_car_sound(id, sound_type, sound_state):
	players[id][sound_type] = sound_state
	
func check_horn():
	if players[name]["horn"]:
		if not $AudioStreamPlayer3DHorn.is_playing():
			$AudioStreamPlayer3DHorn.play()
	else:
		$AudioStreamPlayer3DHorn.stop()
	
func check_siren():
	if players[name]["siren"]:
		$Siren/ArestArea.monitoring = true
		if not $Siren/AnimationPlayer.is_playing():
			$Siren/AnimationPlayer.play("Siren")
		if not $Siren/AudioStreamPlayer3D.is_playing():
			$Siren/AudioStreamPlayer3D.play()
		$Siren/SirenMesh/SpotLight3DBlue.show()
		$Siren/SirenMesh/SpotLight3DRed.show()
	else:
		$Siren/ArestArea.monitoring = false
		$Siren/AnimationPlayer.stop()
		$Siren/AudioStreamPlayer3D.stop()
		$Siren/SirenMesh/SpotLight3DBlue.hide()
		$Siren/SirenMesh/SpotLight3DRed.hide()


func _on_audio_stream_player_3d_horn_finished() -> void:
	if not Network.local_player_id == 1:
		rpc_id(1, "toggle_car_sound", name, "horn", false)
	else:
		toggle_car_sound(name, "horn", false)

func _on_arest_area_body_entered(body: Node3D) -> void:
	body.criminal_detected = true 

func _on_arest_area_body_exited(body: Node3D) -> void:
	body.criminal_detected = false 

func increment_arrest_value():
	arrest_value += 1
	$PlayerBillboard/PlayerBillboardSubViewport/TextureProgressBar.value = arrest_value
	if arrest_value == max_arrest_value:
		get_tree().call_group("Announcements", "victory", false)

