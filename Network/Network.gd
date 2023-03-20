extends Node

const DEFAULT_IP = "127.0.0.1"
const DEFAULT_PORT = 32023
const MAX_PLAYERS = 4

var peer = ENetMultiplayerPeer.new()
var players = {} # Dictionary of all player datas
var player_data = {} # local player data
var local_player_id = 0
var selected_ip
var selected_port
var ready_players = 0
var is_cop = false

signal player_disconnected
signal server_disconnected

func dlog(text: String):
	var isServerStr = ""
	if multiplayer.is_server(): 
		isServerStr = "!"
	print("#" + str(local_player_id) + isServerStr + ": " + text)

func _ready():
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_connected.connect(_connected_to_server)

func create_server():
	peer.create_server(selected_port, MAX_PLAYERS)
	multiplayer.multiplayer_peer = peer
	add_to_player_list()

func connect_to_server():
	peer.create_client(selected_ip, selected_port)
	multiplayer.multiplayer_peer = peer


func add_to_player_list():
	local_player_id = multiplayer.get_unique_id()
	player_data = Save.save_data
	players[local_player_id] = player_data
	players[local_player_id]["is_cop"] = is_cop

func _connected_to_server(_id):
	add_to_player_list()
	rpc("_send_player_info", local_player_id, player_data)
	
@rpc("any_peer")
func _send_player_info(id, player_info, cop_mode):
	players[id] = player_info
	players[id]["is_cop"] = cop_mode
	if multiplayer.is_server():
		rpc("_update_players", players)
		rpc("update_waiting_room")

@rpc
func _update_players(player_info):
#	dlog("_updates_players.")
	players = player_info

func _on_player_connected(_id):
	dlog("has connected")

func _on_player_disconnected(id):
	if not id == 1:
		dlog("has disconnected.")
		
@rpc("any_peer", "call_local")
func update_waiting_room():
	get_tree().call_group("WaitingRoom", "refresh_players", players)
	
func start_game():
	rpc("load_world")
	
@rpc("any_peer", "call_local")
func load_world():
	get_tree().change_scene_to_file("res://World/world.tscn")
		
