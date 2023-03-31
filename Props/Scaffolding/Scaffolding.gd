@tool
extends Node3D

var has_finished_spawning = false
var is_physics_active = false

func _on_timer_timeout():
	await Helper.fade_out(self)
	queue_free()
	
func _on_scaffold_pole_sleeping_state_changed():
	if not $ScaffoldPole.sleeping and has_finished_spawning:
		if $Timer.is_stopped():
			$Timer.start()

func _on_scaffold_pole_body_entered(body: Node) -> void:
	if body is GridMap and not has_finished_spawning:
		has_finished_spawning = true
