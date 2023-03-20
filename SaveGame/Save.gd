extends Node

var save_data = {}
const SAVEGAME = "user://Savegame.json"

func _ready():
	save_data = get_data()

func get_data():
	if not FileAccess.file_exists(SAVEGAME):
		save_data = {"Player_name": "Unnamed"}
		save_game()
		
	var file = FileAccess.open(SAVEGAME, FileAccess.READ)	
	print(str(file.get_path()))
	var content = file.get_as_text()
	
	var json_object = JSON.new()
	var _parse_err = json_object.parse(content)
	save_data = json_object.get_data()
	file.close()
	return(save_data)
	
func save_game():
	var file = FileAccess.open(SAVEGAME, FileAccess.WRITE)
	file.store_line(JSON.stringify(save_data))
