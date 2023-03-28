extends Area3D

var size
var player
var wait

func _ready() -> void:
	wait = $Timer.wait_time
	if Network.is_cop:
		hide()


func _physics_process(_delta: float) -> void:
	if not $Timer.is_stopped():
		size = $Timer.time_left / wait
		$CSGCylinder3D.scale.x = size
		$CSGCylinder3D.scale.z = size
	else:
		$CSGCylinder3D.scale.x = 1
		$CSGCylinder3D.scale.z = 1

func _on_body_entered(body: Node3D) -> void:
	player = body
	$Timer.start()
	show()

func _on_body_exited(_body: Node3D) -> void:
	$Timer.stop()
	player = null

func _on_timer_timeout() -> void:
	queue_free()
