extends Camera3D

var East_West_line
var North_Sound_line

var neighbourhood

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	make_neighbourhoods()


func make_neighbourhoods():
	East_West_line = (Network.city_size.x * 20) / 2
	North_Sound_line = (Network.city_size.y * 20) / 2
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if East_West_line != null:
		manage_bus_levels()
		
func manage_bus_levels():
	var n1 = global_transform.origin.x < East_West_line and global_transform.origin.z < North_Sound_line
	var n2 = global_transform.origin.x < East_West_line and global_transform.origin.z > North_Sound_line
	var n3 = global_transform.origin.x > East_West_line and global_transform.origin.z < North_Sound_line
	var n4 = global_transform.origin.x > East_West_line and global_transform.origin.z > North_Sound_line
	neighbourhood = {
		3: n1,
		4: n2,
		5: n3,
		6: n4
	}
	for i in range(3, 7):
		AudioServer.set_bus_mute(i, !neighbourhood[i])
