extends CanvasLayer

@onready var NameTextBox = $MarginContainer/VBoxContainer/CenterContainer/GridContainer/NameTextbox
@onready var SelectedPort = $MarginContainer/VBoxContainer/CenterContainer/GridContainer/PortTextbox
@onready var SelectedIP = $MarginContainer/VBoxContainer/CenterContainer/GridContainer/IPTextbox

var isCop = false
var city_size
var environment = "res://Environments/night.tres"
var minimap_environment = "res://Environments/minimap-night.tres"

func _ready():
	NameTextBox.text = Save.save_data["Player_name"]
	SelectedIP.text = Network.DEFAULT_IP
	SelectedPort.text = str(Network.DEFAULT_PORT)
	_on_city_size_button_item_selected(1)
	_on_time_check_item_selected(0)
	$MarginContainer/VBoxContainer/CenterContainer/GridContainer/ColorPickerButton.color = Save.save_data["local_paint_color"]
	
func _on_host_button_pressed():
	Network.selected_port = int(SelectedPort.text)
	Network.is_cop = isCop
	Network.create_server()
	Network.city_size = city_size
	Network.environment = environment
	Network.minimap_environment = minimap_environment
	generate_city_seed()
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

func _on_team_check_item_selected(index: int) -> void:
	if not int(isCop) == index:
		var button = $MarginContainer/VBoxContainer/CenterContainer/GridContainer/TeamCheck
		button.set_item_disabled(0, true)
		button.set_item_disabled(1, true)
		isCop = index
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
	var world_seed = $MarginContainer/VBoxContainer/CenterContainer/GridContainer/CitySeed.text
	if world_seed == "":
		Network.world_seed = randi()
	else:
		Network.world_seed = hash(world_seed)

func _on_time_check_item_selected(index: int) -> void:
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
