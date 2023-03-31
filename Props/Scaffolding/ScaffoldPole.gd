extends RigidBody3D

const pipe_sounds = [
	preload("res://SFX/Pipes/Pipe1.ogg"),
	preload("res://SFX/Pipes/Pipe2.ogg"),
	preload("res://SFX/Pipes/Pipe3.ogg"),
	preload("res://SFX/Pipes/Pipe4.ogg")
]
func _on_body_entered(_body: Node) -> void:
	if not sleeping and get_parent().is_physics_active and not $AudioStreamPlayer3D.playing:
		pick_sound()
		$AudioStreamPlayer3D.play()
		
func pick_sound():
	$AudioStreamPlayer3D.stream = pipe_sounds[randi() % pipe_sounds.size()]

func _on_sleeping_state_changed() -> void:
	if sleeping and not get_parent().is_physics_active:
		get_parent().is_physics_active = true
		Helper.activate_collision(get_parent())
