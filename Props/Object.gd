extends RigidBody3D

var has_finished_spawning = false

func _on_timer_timeout():
	await Helper.fade_out(self)
	queue_free()

func _on_body_entered(_body):
	if not $AudioStreamPlayer3D.playing and has_finished_spawning:
		$AudioStreamPlayer3D.pitch_scale = 1 + randf() / 2
		$AudioStreamPlayer3D.play()
	else:
		has_finished_spawning = true
		
func _on_sleeping_state_changed():
	if not sleeping and has_finished_spawning:
		$Timer.start()
	
