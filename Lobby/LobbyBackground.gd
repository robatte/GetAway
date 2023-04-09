extends Node3D

var paint:BaseMaterial3D
var default_color

func _ready() -> void:
	make_material()
	default_color = Color(Save.save_data["local_paint_color"])
	apply_defaults()

func pivot():
	$AudioStreamPlayer.play()
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_EXPO)
	tween.tween_property($Pivot, "rotation_degrees:y", 180, 1).as_relative()
	await tween.finished
	
func make_material():
	var new_paint = load("res://Lobby/DefaultCarPaint1.tres")
	$Pivot/Criminal1.set_surface_override_material(0, new_paint)
	$Pivot/Criminal2.set_surface_override_material(0, new_paint)
	$Pivot/Cop1.set_surface_override_material(0, new_paint)
	$Pivot/Cop2.set_surface_override_material(0, new_paint)
	paint = $Pivot/Cop1.get_surface_override_material(0)
 
func apply_defaults():
	paint.metallic = 0.75
	paint.metallic_specular = 0.25
	paint.roughness = 0.25
	paint.albedo_color = default_color

func new_color(color):
	paint.albedo_color = color
