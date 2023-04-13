extends ReferenceRect



func _on_audio_button_pressed() -> void:
	$ColorRect/MarginContainer/CenterContainer/AudioMenu.show()


func _on_video_button_pressed() -> void:
	$ColorRect/MarginContainer/CenterContainer/VideoMenu.show()


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_done_button_pressed() -> void:
	hide()
