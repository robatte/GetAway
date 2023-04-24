extends ReferenceRect



func _on_audio_button_pressed() -> void:
	$ColorRect/MarginContainer/CenterContainer/AudioMenu.show()


func _on_video_button_pressed() -> void:
	$ColorRect/MarginContainer/CenterContainer/VideoMenu.show()


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_done_button_pressed() -> void:
	hide()


func _on_restart_button_pressed() -> void:
#	await get_tree().process_frame
	Network.reset_game()
#	get_tree().unload_current_scene()
#	var err = load("res://Lobby/lobby.tscn")
	pass
