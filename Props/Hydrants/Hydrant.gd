extends Node3D

var has_finished_spawning = false

func _on_timer_timeout():
	await Helper.fade_out(self)
	queue_free()

func _on_fire_hydrant_sleeping_state_changed():
	if not $FireHydrant.sleeping and has_finished_spawning:
		$GPUParticles3D.emitting = true
		$Timer.start()
	else:
		has_finished_spawning = true
