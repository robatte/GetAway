extends Camera3D

@onready var car = get_owner().get_parent()

const minimum_height = 50
var speed = 0

func _process(_delta: float) -> void:
	var height = speed * 2 + minimum_height
	position = Vector3(car.position.x, height, car.position.z)

func update_speed(new_speed):
	speed = new_speed
