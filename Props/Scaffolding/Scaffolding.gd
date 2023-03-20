extends Node3D

var has_finished_spawning = false

func _on_timer_timeout():
	await Helper.fade_out(self)
	queue_free()
	
func _on_scaffold_pole_sleeping_state_changed():
	if not $ScaffoldPole.sleeping and has_finished_spawning:
		$Timer.start()
	else:
		has_finished_spawning = true
