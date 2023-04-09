extends Node

const MASTER_BUS = 0
const SFX_BUS = 1
const MUSIC_BUS = 2

func _ready():
	var master_volume = Save.save_data["master_volume"]
	var music_volume = Save.save_data["music_volume"]
	var sfx_volume = Save.save_data["sfx_volume"]

	AudioServer.set_bus_volume_db(MASTER_BUS, master_volume)
	AudioServer.set_bus_volume_db(SFX_BUS, sfx_volume)
	AudioServer.set_bus_volume_db(MUSIC_BUS, music_volume)

func update_master_volume(master_volume):
	AudioServer.set_bus_volume_db(MASTER_BUS, master_volume)
	Save.save_data["master_volume"] = master_volume
	Save.save_game()

func update_music_volume(music_volume):
	AudioServer.set_bus_volume_db(MUSIC_BUS, music_volume)
	Save.save_data["music_volume"] = music_volume
	Save.save_game()
	
func update_sfx_volume(sfx_volume):
	AudioServer.set_bus_volume_db(SFX_BUS, sfx_volume)
	Save.save_data["sfx_volume"] = sfx_volume
	Save.save_game()
