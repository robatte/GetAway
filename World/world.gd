extends Node3D

var money_stashed = 0:
	set(cash):
		money_stashed = cash
		Helper.Log("[color=red]Money[/color]", str(money_stashed))
var money_recovered = 0

@export var criminals_victory_score = 1000
@export var cops_victory_score = 3000

var cop_spawn_point: Vector3

@export var desired_fps = 90
const perf_measure_time = 3
var perf_values = []
var optimize_queue = [
	{"task": "set_msaa", 		"value": 1},
	{"task": "set_dof", 		"value": false},
	{"task": "set_fsr_scale", 	"value": 3},
	{"task": "set_far_camera", 	"value": 1},
	{"task": "set_reflections", "value": false},
	{"task": "set_fsr_scale",	"value": 2},
	{"task": "set_msaa", 		"value": 0},
	{"task": "set_particles", 	"value": 1},
	{"task": "set_far_camera",	"value": 0},
	{"task": "set_particles", 	"value": 0},
	{"task": "set_fsr_scale",	"value": 1},
]

	
func _enter_tree():
	get_tree().set_pause(true)
	
func _start():
	await get_tree().create_timer(3, false).timeout
	if Save.save_data["optimize_performance"]:
		Helper.notify("Start optimizing graphic settings in order to achieve " + str(desired_fps) + "fps:")
		$AccumulateFpsTimer.start()
	
func spawn_local_player():
	var new_player = preload("res://Player/player.tscn").instantiate()
	new_player.name = str(Network.local_player_id)
	new_player.translate(Vector3(10, 3, 12))
	$Players.add_child(new_player)
	if Network.is_cop:
		await get_tree().process_frame
		new_player.position = cop_spawn_point

func remove_player(id):
	rpc("_remove_player", id)
	
@rpc("call_local", "reliable")
func _remove_player(id):
	var player_to_remove = $Players.get_node(str(int(id)))
	if player_to_remove:
		Helper.Log("World", "Remove Player #" + str(player_to_remove))
		$Players.remove_child(player_to_remove)
		player_to_remove.queue_free()

@rpc("any_peer", "reliable")
func spawn_remote_player(id):
	var new_player = preload("res://Player/player.tscn").instantiate()
	new_player.name = str(id)
	new_player.translate(Vector3(10 + randi() % 10, 3, 12))
	$Players.add_child(new_player)
	if Network.players[int(str(id))]["is_cop"]:
		await get_tree().process_frame
		new_player.position = Vector3(randi() % 10, 0, 0) + cop_spawn_point

func unpause():
	spawn_local_player()
	rpc("spawn_remote_player", Network.local_player_id)
	get_tree().set_pause(false)
	if Network.environment == "res://Environments/night.tres":
		$Sun.queue_free()
	else:
		get_tree().call_group("lights", "queue_free")
		
	get_tree().call_group("started", "_start")
	
	
@rpc("any_peer", "call_remote", "reliable")
func update_gamestate(stashed, recovered):
	if multiplayer.is_server():
		money_stashed += stashed
		money_recovered += recovered
		Helper.Log("Gamestate", "stashed: " + str(money_stashed) + "/" + str(criminals_victory_score) + ", recovred: " + str(money_recovered) + "/" + str(cops_victory_score))
		check_win_conditions()
	else:
		print(str(multiplayer.get_remote_sender_id()) + "update gamestate call server")
		rpc_id(1, "update_gamestate", stashed, recovered)
		
func check_win_conditions():
	print("CheckWinCondition by " + str(Network.local_player_id))
	if money_stashed >= criminals_victory_score:
		get_tree().call_group("Announcements", "victory", true)
	elif money_recovered >= cops_victory_score:
		get_tree().call_group("Announcements", "victory", false)


func _on_object_spawner_cop_spawn(location: Vector3) -> void:
	Helper.Log("World", "Spawn Cop at " + str(location))
	cop_spawn_point = location

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("menu"):
		$InGameMenu.visible = !$InGameMenu.visible


func _on_accumulate_fps_timer_timeout() -> void:
	perf_values.append(Performance.get_monitor(Performance.TIME_FPS))
	
	if perf_values.size() >= perf_measure_time:
		$AccumulateFpsTimer.stop()
		var fps = 0.0
		for val in perf_values:
			fps += val
		fps /= perf_values.size()
		perf_values.clear()
		if fps < desired_fps:
			optimize_performance()
		else:
			get_tree().call_group("video", "set_optimize_performance", false, true)
			Helper.notify("Check. Performance good :)")
		
func optimize_performance():
	if optimize_queue.size() == 0:
		Helper.notify("All performance optmizations done. Sorry.")
	else:
		var task = optimize_queue.pop_front()
		get_tree().call_group("video", task.task, task.value, true)
		$AccumulateFpsTimer.start()
	
