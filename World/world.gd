extends Node3D

func _enter_tree():
	get_tree().paused = true
	print("World...")
	
func spawn_local_player():
	var new_player = preload("res://Player/player.tscn").instantiate()
	new_player.name = str(Network.local_player_id)
	new_player.translate(Vector3(12, 3, 12))
	$Players.add_child(new_player)

@rpc("any_peer")
func spawn_remote_player(id):
	var new_player = preload("res://Player/player.tscn").instantiate()
	new_player.name = str(id)
	new_player.translate(Vector3(12, 3, 12))
	$Players.add_child(new_player)

func unpause():
	spawn_local_player()
	rpc("spawn_remote_player", Network.local_player_id)
	get_tree().paused = false
