extends Node3D

var money_stashed = 0:
	set(cash):
		money_stashed = cash
		Helper.Log("[color=red]Money[/color]", str(money_stashed))
var money_recovered = 0

@export var criminals_victory_score = 1000
@export var cops_victory_score = 3000

var cop_spawn_point: Vector3

func _enter_tree():
	get_tree().set_pause(true)
	
func spawn_local_player():
	var new_player = preload("res://Player/player.tscn").instantiate()
	new_player.name = str(Network.local_player_id)
	new_player.translate(Vector3(10, 3, 12))
	$Players.add_child(new_player)
	if Network.is_cop:
		await get_tree().process_frame
		new_player.position = cop_spawn_point

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
		$AudioMenu.show()
