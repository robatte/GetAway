extends BoxContainer

var has_started = false

const fsr_scale_dict = [
	"Performance",
	"Balanced",
	"Quality",
	"Ultra Quality",
	"Nativ",
]
const msaa_dict = [
	"Off",
	"2",
	"4",
	"8"
]
const far_cam_dict = ["Near", "Far Enough", "Far"]
const particles_dict = ["Off", "Some", "Full"]
const reflections_dict = ["Off", "On"]
const dof_dict = ["Off", "On"]
const fullscreen_dict = ["Off", "On"]
const optimize_dict = ["No", "Yes"]

@onready var fullscreen_check = $ColorRect/MarginContainer/VBoxContainer/CenterContainer/GridContainer/FullscreenCheck
@onready var fullscreen_label = $ColorRect/MarginContainer/VBoxContainer/CenterContainer/GridContainer/FullscreenValueLabel
@onready var optimize_check = $ColorRect/MarginContainer/VBoxContainer/CenterContainer/GridContainer/OptimizeCheck
@onready var optimize_label = $ColorRect/MarginContainer/VBoxContainer/CenterContainer/GridContainer/OptimizeValueLabel
@onready var dof_check = $ColorRect/MarginContainer/VBoxContainer/CenterContainer/GridContainer/DofCheck
@onready var dof_label = $ColorRect/MarginContainer/VBoxContainer/CenterContainer/GridContainer/DofValueLabel
@onready var reflections_check = $ColorRect/MarginContainer/VBoxContainer/CenterContainer/GridContainer/ReflextionsCheck
@onready var reflections_label = $ColorRect/MarginContainer/VBoxContainer/CenterContainer/GridContainer/ReflectionsValueLabel
@onready var particles_slide = $ColorRect/MarginContainer/VBoxContainer/CenterContainer/GridContainer/ParticlesCheck
@onready var particles_label = $ColorRect/MarginContainer/VBoxContainer/CenterContainer/GridContainer/ParticlesValueLabel
@onready var msaa_check = $ColorRect/MarginContainer/VBoxContainer/CenterContainer/GridContainer/MSAACheck
@onready var msaa_label = $ColorRect/MarginContainer/VBoxContainer/CenterContainer/GridContainer/MSAAValueLabel
@onready var far_camera_slide = $ColorRect/MarginContainer/VBoxContainer/CenterContainer/GridContainer/HighDistanceCheck
@onready var far_camera_label = $ColorRect/MarginContainer/VBoxContainer/CenterContainer/GridContainer/HighDistanceValueLabel
@onready var fsr_scale_slide = $ColorRect/MarginContainer/VBoxContainer/CenterContainer/GridContainer/FSRCheck
@onready var fsr_scale_label = $ColorRect/MarginContainer/VBoxContainer/CenterContainer/GridContainer/FSRValueLabel
@onready var fps_overlay = $ColorRect/FPS


func _start():
	has_started = true
	
func _ready() -> void:
	set_fullscreen(Save.save_data["fullscreen"])
	set_optimize_performance(Save.save_data["optimize_performance"])
	set_dof(Save.save_data["dof"])
	set_reflections(Save.save_data["reflections"])
	set_particles(Save.save_data["particles"])
	set_far_camera(Save.save_data["far_camera"])
	set_fsr_scale(Save.save_data["fsr_scale"])
	set_msaa(Save.save_data["msaa"])
	
	fps_overlay.button_pressed = Save.save_data["show_fps"]


# Set Depth Of Field blur option
func set_dof(value: bool, notify = false):
	dof_check.button_pressed = value
	if notify: Helper.notify("Set DepthOfField blur to: \"" + dof_dict[int(value)] + "\"")
	
func _on_dof_check_toggled(button_pressed: bool) -> void:
	dof_label.text = dof_dict[int(button_pressed)]
	Save.save_data["dof"] = button_pressed
	Save.save_game()
	get_tree().call_group("cameras", "dof_blur")


# Set reflections option	
func set_reflections(value: bool, notify = false):
	reflections_check.button_pressed = value
	if notify: Helper.notify("Set reflections to " + reflections_dict[int(value)])
	
func _on_reflextions_check_toggled(button_pressed: bool) -> void:
	reflections_label.text = reflections_dict[int(button_pressed)]
	Save.save_data["reflections"] = button_pressed
	Save.save_game()
	get_tree().call_group("cameras", "ssr")


# Set particle amount option
func set_particles(value: bool, notify = false):
	particles_slide.value = value
	if notify: Helper.notify("Set particles to: \"" + particles_dict[int(value)] + "\"")

func _on_particles_check_value_changed(value: float) -> void:
	particles_label.text = particles_dict[int(value)]
	Save.save_data["particles"] = int(value)
	Save.save_game()
	get_tree().call_group("particles", "manage_particles")


# Set Camera view distance option
func set_far_camera(value: int, notify = false):
	far_camera_slide.value = value
	if notify: Helper.notify("Set camera distance to: \"" + far_cam_dict[int(value)] + "\"")
	
func _on_high_distance_check_value_changed(value: float) -> void:
	far_camera_label.text = far_cam_dict[int(value)]
	Save.save_data["far_camera"] = int(value)
	Save.save_game()
	get_tree().call_group("cameras", "far_camera")


func set_msaa(value: int, notify = false):
	msaa_check.value = value
	if notify: Helper.notify("Set MSAA to: \"" + msaa_dict[value] + "\"")
	
func _on_msaa_check_value_changed(value: float) -> void:
	msaa_label.text = msaa_dict[int(value)]
	Save.save_data["msaa"] = int(value)
	Save.save_game()
	var msaa = Viewport.MSAA_DISABLED
	match int(value):
		0: msaa = Viewport.MSAA_DISABLED
		1: msaa = Viewport.MSAA_2X
		2: msaa = Viewport.MSAA_4X
		4: msaa = Viewport.MSAA_8X
	get_tree().get_root().get_viewport().set_msaa_3d(msaa)
	
	
# Set FidelityFX Super Resolution option
func set_fsr_scale(value: int, notify = false):
	fsr_scale_slide.value = value
	if notify: Helper.notify("Set FSR scale to: \"" + fsr_scale_dict[int(value)] + "\"")
	
func _on_fsr_check_value_changed(value: float) -> void:
	fsr_scale_label.text = fsr_scale_dict[int(value)]
	Save.save_data["fsr_scale"] = int(value)
	Save.save_game()
	get_tree().call_group("cameras", "fsr_scaling")


# Set fullscreen option
func set_fullscreen(value: bool):
	fullscreen_check.button_pressed = value
		
func _on_fullscreen_check_toggled(button_pressed: bool) -> void:
	fullscreen_label.text = fullscreen_dict[int(button_pressed)]
	Save.save_data["fullscreen"] = button_pressed
	Save.save_game()
	if Save.save_data["fullscreen"]:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


# Set Optimize performance settings
func set_optimize_performance(value: bool, notify = false):
	optimize_check.button_pressed = value
	if notify: Helper.notify("Set Optimize performance to: \"" + optimize_dict[int(value)] + "\"")
	
func _on_optimize_check_toggled(button_pressed: bool) -> void:
	optimize_label.text = optimize_dict[int(button_pressed)]
	Save.save_data["optimize_performance"] = button_pressed
	Save.save_game()


func _on_done_button_pressed() -> void:
	hide()

func update_fps():
	$ColorRect/FPS.text = str(Performance.get_monitor(Performance.TIME_FPS)) + "fps"

func _on_visibility_changed() -> void:
	if visible: 
		$FpsTimer.start()
	else: 
		$FpsTimer.stop()


func _on_fps_toggled(button_pressed: bool) -> void:
	Save.save_data["show_fps"] = button_pressed
	Save.save_game()
	get_tree().call_group("huds", "show_fps")

