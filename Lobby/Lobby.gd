extends Control

@onready var NameTextBox = $MarginContainer/CenterContainer/GridContainer/NameTextbox
@onready var SelectedPort = $MarginContainer/CenterContainer/GridContainer/PortTextbox
@onready var SelectedIP = $MarginContainer/CenterContainer/GridContainer/IPTextbox 

var isCop = false

func _ready():
	NameTextBox.text = Save.save_data["Player_name"]
	SelectedIP.text = Network.DEFAULT_IP
	SelectedPort.text = str(Network.DEFAULT_PORT)

func _on_host_button_pressed():
	Network.selected_port = int(SelectedPort.text)
	Network.is_cop = isCop
	Network.create_server()
	get_tree().call_group("HostOnly", "show")
	create_waiting_room()


func _on_join_button_pressed():
	Network.selected_ip = SelectedIP.text
	Network.selected_port = int(SelectedPort.text)
	Network.is_cop = isCop
	Network.connect_to_server()
	create_waiting_room()

func _on_name_textbox_text_changed(_new_text):
	Save.save_data["Player_name"] = NameTextBox.text
	Save.save_game()

func create_waiting_room():
	$WaitingRoom.show()
	$WaitingRoom.refresh_players(Network.players)


func _on_ready_button_pressed():
	Network.start_game()


func _on_team_check_toggled(button_pressed):
	isCop = button_pressed
