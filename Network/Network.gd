@tool
extends Node

const DEFAULT_IP = "127.0.0.1"
const DEFAULT_PORT = 32023
const MAX_PLAYERS = 4

var players = {} # Dictionary of all player datas
var player_data = {} # local player data
var peer = ENetMultiplayerPeer.new()
var local_player_id = 0
var selected_ip
var selected_port
var ready_players = 0
var is_cop = false
var is_waiting = false
var city_size = Vector2()
var prop_multiplier = 1
var world_seed = 0
var environment
var minimap_environment

signal player_disconnected
signal server_disconnected


func _ready():
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_connected_to_server)
	multiplayer.server_disconnected.connect(_server_offline)

func create_server():
	if peer:
		peer.close()
	Helper.Log("Network", "Create Server")
	local_player_id = 0
	players.clear()
	peer = ENetMultiplayerPeer.new()
	peer.create_server(selected_port, MAX_PLAYERS)
	multiplayer.multiplayer_peer = peer
	_connected_to_server()
	

func connect_to_server():
	Helper.Log("Network", "connects to server")
	if peer:
		peer.close()

#	local_player_id = 0
	players.clear()
	peer = ENetMultiplayerPeer.new()
	peer.create_client(selected_ip, selected_port)
	multiplayer.multiplayer_peer = peer


func add_to_player_list():
#	if not local_player_id:
	local_player_id = multiplayer.get_unique_id()
	player_data = Save.save_data
	players[local_player_id] = player_data
	players[local_player_id]["is_cop"] = is_cop
	players[local_player_id]["is_waiting_ready"] = is_waiting
	players[local_player_id]["paint_color"] = Save.save_data["local_paint_color"]


func set_player_waiting_ready(id, is_waiting_ready: bool):
	is_waiting = is_waiting_ready
	rpc_id(1, "_send_player_info", id, player_data, is_cop, is_waiting_ready)


func set_player_team(id, team):
	is_cop = team
	rpc_id(1, "_send_player_info", id, player_data, is_cop, is_waiting)
	
func set_player_name(id, player_name):
	player_data.Player_name = player_name
	rpc_id(1, "_send_player_info", id, player_data, is_cop, is_waiting)
	
func set_daytime(index):
	rpc("_send_day_time", index)

@rpc("authority", "call_local", "reliable")
func _send_day_time(index):
	if not multiplayer.is_server():
		get_tree().call_group("Lobby", "set_daytime", index)
	
@rpc("any_peer", "call_local", "reliable")
func _send_player_info(id, player_info, cop_mode, is_waiting_ready = false):
	players[id] = player_info
	players[id]["is_cop"] = cop_mode
	players[id]["is_waiting_ready"] = is_waiting_ready
	if multiplayer.is_server():
		rpc("_update_players", players)
		rpc("update_waiting_room")
		var all_waiting = true
		for player_id in players:
			if not players[player_id]["is_waiting_ready"]:
				all_waiting = false
				break
		get_tree().call_group("Lobby", "set_start_button", all_waiting)

@rpc("reliable")
func _update_players(player_info):
	Helper.Log("Player", "updates players info")
	players = player_info

func _connected_to_server():
	add_to_player_list()
	Helper.Log("Player", "has connected")
	rpc_id(1, "_send_player_info", local_player_id, player_data, is_cop, is_waiting)

func _server_offline():
	Helper.Log("Network", "server offline")
	players.clear()
	reset_game()
	
func _on_player_disconnected(id):
	Helper.Log("Network", "on_player_disconnected")
	if multiplayer.is_server():
		players.erase(id)
		get_tree().call_group("GameState", "remove_player", id)
		rpc("_update_players", players)
		rpc("update_waiting_room")
	pass
		
@rpc("any_peer", "call_local", "reliable")
func update_waiting_room():
	Helper.Log("Player", "updates WaitingRoom")
	get_tree().call_group("WaitingRoom", "refresh_players", players)
	
func start_game():
	rpc("load_world", environment, minimap_environment)
	
@rpc("any_peer", "call_local", "reliable")
func load_world(selected_environment, selected_minimap_environment):
	environment = selected_environment
	minimap_environment = selected_minimap_environment
	get_tree().change_scene_to_file("res://World/world.tscn")
		
func reset_game():
	get_tree().paused = true
	var err = get_tree().change_scene_to_file("res://Lobby/lobby.tscn")
	print(err)
	get_tree().paused = false
