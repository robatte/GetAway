extends Node3D
# A simple hydrant

var has_finished_spawning = false

# timer timeout
func _on_timer_timeout():
	await Helper.fade_out(self)
	queue_free()

func _on_fire_hydrant_body_entered(body: Node) -> void:
	if body is GridMap and not has_finished_spawning:
		has_finished_spawning = true
	elif not $FireHydrant.sleeping and has_finished_spawning:
		$Water.emitting = true
		$Drops.emitting = true
		$Timer.start()
		await get_tree().create_timer(0.2).timeout
		$Foam.emitting = true

func manage_particles(value):
	match value:
		0: 
			$Water.hide()
			$Drops.hide()
			$Foam.hide()
		1: 
			$Water.show()
			$Drops.show()
			$Foam.show()
			$Drops.amount = 64
			$Foam.amount = 64
			
		2: 
			$Water.show()
			$Drops.show()
			$Foam.show()
			$Drops.amount = 256
			$Foam.amount = 128

