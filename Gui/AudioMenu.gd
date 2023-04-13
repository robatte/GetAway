extends BoxContainer

func _ready() -> void:
	$ColorRect/MarginContainer/VBoxContainer/CenterContainer/MasterSlider.value = Save.save_data["master_volume"]
	$ColorRect/MarginContainer/VBoxContainer/CenterContainer/MusicSlider.value = Save.save_data["music_volume"]
	$ColorRect/MarginContainer/VBoxContainer/CenterContainer/SfxSlider.value = Save.save_data["sfx_volume"]
	
func _on_master_slider_value_changed(value: float) -> void:
	VolumeControl.update_master_volume(value)


func _on_music_slider_value_changed(value: float) -> void:
	VolumeControl.update_music_volume(value)


func _on_sfx_slider_value_changed(value: float) -> void:
	VolumeControl.update_sfx_volume(value)


func _on_done_button_pressed() -> void:
	hide()
