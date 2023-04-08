extends Node3D

var destination = Vector3(0,0,0)

func _process(_delta: float) -> void:
	look_at(destination)

func new_destination(newDestination):
	destination = newDestination
	$AnimationPlayer.play("Reveal")
