extends Area3D

## The actual radius*2 of the beacon.
var size

## The current player acting with the beacon
var player

## Waiting time that has to pass while acting with an player to trigger an action
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
	print("Beacon player: " + str(body))
	get_tree().call_group("Announcements", "announce_crime", position)

func _on_body_exited(_body: Node3D) -> void:
	$Timer.stop()
	player = null

func _on_timer_timeout() -> void:
	Helper.Log("Beacon", str(player) + " finished beacon")
#	if player.name == str(Network.local_player_id):
	player.beacon_emptied()
	queue_free()
