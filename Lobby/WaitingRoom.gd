extends Control

@onready var PlayerList = %ItemList

func _ready():
	PlayerList.clear()

func refresh_players(players):
	PlayerList.clear()
#	Helper.Log("WaitingRoom", "update player list with " + str(players.size()) + " players.")
	for player_id in players:
		var player = players[player_id]["Player_name"]
		if players[player_id]["is_waiting_ready"]: 
			player += " ✓"
		var team_icon = load("res://Gui/criminal.svg")
		if players[player_id]["is_cop"]:
			team_icon = load("res://Gui/cop.svg")
		PlayerList.add_item(player, team_icon, false)

func reset_ready():
	$Panel/VBoxContainer/ReadyButton.set_pressed(false)

func _on_ready_button_toggled(button_pressed: bool) -> void:
	Network.is_waiting = button_pressed
	Network.set_player_waiting_ready(Network.local_player_id, button_pressed)
