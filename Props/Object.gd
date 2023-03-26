extends RigidBody3D

var has_finished_spawning = false

func _on_timer_timeout():
	await Helper.fade_out(self)
	queue_free()

func _on_body_entered(body):
	if body is GridMap and not has_finished_spawning:
		has_finished_spawning = true
		sleeping = true	
	elif not $AudioStreamPlayer3D.playing and has_finished_spawning:
		$AudioStreamPlayer3D.play()
		

func _on_sleeping_state_changed():
	if not sleeping and has_finished_spawning:
		$Timer.start()
	
