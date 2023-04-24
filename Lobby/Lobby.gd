extends CanvasLayer

@onready var NameTextBox = $MarginContainer/VBoxContainer/Grid/GridContainer/NameTextbox
@onready var SelectedPort = $MarginContainer/VBoxContainer/Grid/GridContainer/PortTextbox
@onready var SelectedIP = $MarginContainer/VBoxContainer/Grid/GridContainer/IPTextbox
@onready var SelectDayTime = $MarginContainer/VBoxContainer/Grid/GridContainer/TimeCheck

var is_host = false
var isCop = false
var city_size
var environment = "res://Environments/night.tres"
var minimap_environment = "res://Environments/minimap-night.tres"

func _ready():
	NameTextBox.text = Save.save_data["Player_name"]
	$PlayerLabel.text = NameTextBox.text + "' Garage"
	Network.set_player_name(Network.local_player_id, Save.save_data["Player_name"])
	SelectedIP.text = Network.DEFAULT_IP
	SelectedPort.text = str(Network.DEFAULT_PORT)
	_on_city_size_button_item_selected(1)
	_on_time_check_item_selected(0)
	$MarginContainer/VBoxContainer/Grid/GridContainer/ColorPickerButton.color = Save.save_data["local_paint_color"]
	select_host_or_client()

func select_host_or_client():
	if is_host:
		get_tree().call_group("ClientOnly", "hide")
		get_tree().call_group("HostOnly", "show")
		host_game()
	else:
		get_tree().call_group("HostOnly", "hide")
		get_tree().call_group("ClientOnly", "show")
		join_game()

	
func host_game():
	Network.ready_players = 0
	Network.prop_multiplier = 1
	Network.world_seed = 0
	Network.players = {}
	
	Network.selected_port = int(SelectedPort.text)
	Network.is_cop = isCop
	Network.is_waiting = true
	Network.create_server()
	create_waiting_room()
	

func join_game():
	Network.selected_ip = SelectedIP.text
	Network.selected_port = int(SelectedPort.text)
	Network.is_cop = isCop
	Network.is_waiting = false
	Network.connect_to_server()
	create_waiting_room()

func _on_name_textbox_text_changed(new_text):
	$PlayerLabel.text = NameTextBox.text + "' Garage"
	Save.save_data["Player_name"] = new_text
	Save.save_game()
	Network.set_player_name(Network.local_player_id, new_text)
	get_tree().call_group("WaitingRoom", "reset_ready")

func create_waiting_room():
	$MarginContainer/VBoxContainer/Grid/WaitingRoom.refresh_players(Network.players)


func _on_team_check_item_selected(index: int) -> void:
	if not int(isCop) == index:
		var button = $MarginContainer/VBoxContainer/Grid/GridContainer/TeamCheck
		button.set_item_disabled(0, true)
		button.set_item_disabled(1, true)
		isCop = index
		get_tree().call_group("WaitingRoom", "reset_ready")
		Network.set_player_team(Network.local_player_id, isCop)
		if isCop:
			$LobbyBackground/Pivot/Cop1/Siren/SirenMesh/SpotLight3DRed.show()
			$LobbyBackground/Pivot/Cop1/Siren/SirenMesh/SpotLight3DBlue.show()
			$LobbyBackground/Pivot/Cop1/Siren/AnimationPlayer.play("Siren")
			$LobbyBackground/Pivot/Cop2/Siren/SirenMesh/SpotLight3DRed.show()
			$LobbyBackground/Pivot/Cop2/Siren/SirenMesh/SpotLight3DBlue.show()
			$LobbyBackground/Pivot/Cop2/Siren/AnimationPlayer.play("Siren")
		else:
			$LobbyBackground/Pivot/Cop1/Siren/SirenMesh/SpotLight3DRed.hide()
			$LobbyBackground/Pivot/Cop1/Siren/SirenMesh/SpotLight3DBlue.hide()
			$LobbyBackground/Pivot/Cop1/Siren/AnimationPlayer.stop()
			$LobbyBackground/Pivot/Cop2/Siren/SirenMesh/SpotLight3DRed.hide()
			$LobbyBackground/Pivot/Cop2/Siren/SirenMesh/SpotLight3DBlue.hide()
			$LobbyBackground/Pivot/Cop2/Siren/AnimationPlayer.stop()
			
		await $LobbyBackground.pivot()
		button.set_item_disabled(0, false)
		button.set_item_disabled(1, false)
		button.select(index)


func _on_color_picker_button_color_changed(color: Color) -> void:
	$LobbyBackground.new_color(color)
	Save.save_data["local_paint_color"] = color.to_html()
	Save.save_game()


func _on_city_size_button_item_selected(index: int) -> void:
	match index:
		0:
			city_size = Vector2(10, 10)
			Network.prop_multiplier = 0.5
		1:
			city_size = Vector2(20, 20)
			Network.prop_multiplier = 1
		2:
			city_size = Vector2(40, 40)
			Network.prop_multiplier = 2
		3:
			city_size = Vector2(100, 100)
			Network.prop_multiplier = 5

func generate_city_seed():
	var world_seed = $MarginContainer/VBoxContainer/Grid/GridContainer/CitySeed.text
	if world_seed == "":
		Network.world_seed = randi()
	else:
		Network.world_seed = hash(world_seed)

func set_daytime(index):
	get_tree().call_group("WaitingRoom", "reset_ready")
	_on_time_check_item_selected(index)
	

func _on_time_check_item_selected(index: int) -> void:
	if multiplayer.is_server():
		Network.set_daytime(index)
	match index:
		0:
			environment = "res://Environments/night.tres"
			minimap_environment = "res://Environments/minimap-night.tres"
			$LobbyBackground/Sun.hide()
			$LobbyBackground/Moon.show()
			get_tree().call_group("lights", "show")
		1: 
			environment = "res://Environments/day.tres"
			minimap_environment = "res://Environments/minimap-day.tres"
			$LobbyBackground/Sun.show()
			$LobbyBackground/Moon.hide()
			get_tree().call_group("lights", "hide")
			
	$LobbyBackground/SubViewportContainer/SubViewport/Camera3D.environment = load(environment)


func _on_options_button_pressed() -> void:
	$InGameMenu.visible = ! $InGameMenu.visible

func set_start_button(is_ready):
	$MarginContainer/VBoxContainer/CenterContainer2/PlayButton.set_visible(is_ready)
	
func _on_play_button_pressed() -> void:
	Network.city_size = city_size
	Network.environment = environment
	Network.minimap_environment = minimap_environment
	generate_city_seed()
	Network.start_game()
	
func _on_option_button_item_selected(index: int) -> void:
	is_host = index
	select_host_or_client()


