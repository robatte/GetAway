extends Camera3D

const MAX_CAMERA_ANGLE = 90
const MIN_CAMERA_ANGLE = 70

var East_West_line
var North_Sound_line

var neighbourhood

@export var follow_target: NodePath
@export var target_distance = 10.0
@export var target_height = 1.0

var follow_this:Node3D = null
var last_look_at

@onready var root_viewport = get_tree().get_root()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	make_neighbourhoods()
	set_as_top_level(true)
	environment = load(Network.environment)
	follow_this = get_node(follow_target)
	last_look_at = follow_this.global_transform.origin
	check_saved_settings()

func make_neighbourhoods():
	East_West_line = (Network.city_size.x * 20) / 2
	North_Sound_line = (Network.city_size.y * 20) / 2
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	if East_West_line != null:
		manage_bus_levels()
		
	var delta_v = global_transform.origin - follow_this.global_transform.origin
	var target_position = global_transform.origin
	
	delta_v.y = 0
	if delta_v.length() > target_distance:
		delta_v = delta_v.normalized() * target_distance
		delta_v.y = target_height
		target_position = follow_this.global_transform.origin + delta_v
	else:
		target_position.y = follow_this.global_transform.origin.y + target_height
	
	global_transform.origin = global_transform.origin.lerp(target_position, 1)
	last_look_at = last_look_at.lerp(follow_this.global_transform.origin, 1)
		
	look_at(last_look_at, Vector3.UP)
		
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

func update_speed(speed):
	fov = min(MIN_CAMERA_ANGLE + speed, MAX_CAMERA_ANGLE)

func check_saved_settings():
	dof_blur()
	ssr()
	far_camera()
	fsr_scaling()


func far_camera():
	match Save.save_data["far_camera"]:
		0: far = 300
		1: far = 600
		2: far = 2000	
	
	
func dof_blur():
	attributes.dof_blur_far_enabled = Save.save_data["dof"]
	
	
func ssr():
	environment.ssr_enabled = Save.save_data["reflections"]	


func fsr_scaling():
	var fsr_scale
	match int(Save.save_data["fsr_scale"]):
		0: fsr_scale = 0.5 
		1: fsr_scale = 0.59 
		2: fsr_scale = 0.67 
		3: fsr_scale = 0.77 
		4: fsr_scale = 1.0 
	
	print("set scale3d to " + str(fsr_scale))
#	await get_tree().process_frame 
#	await RenderingServer.frame_post_draw
	get_tree().get_root().scaling_3d_scale = fsr_scale
#	RenderingServer.viewport_set_scaling_3d_scale(get_tree().get_root().get_viewport_rid(), fsr_scale)
