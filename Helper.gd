@tool
extends Node

func fade_out(node, time = 3):
	var TW = create_tween().set_parallel()
	for obj in node.find_children("", "GeometryInstance3D"):
		TW.tween_property(obj, "transparency", 1.0, time)
	return await TW.finished

func activate_collision(node:Node3D):
#	print("activate " + str(node))
	var prop_nodes = node.find_children("", "RigidBody3D") as Array[RigidBody3D]
	for child in prop_nodes:
		child.sleeping = true
		child.gravity_scale = 1.0
		
func deactivate_collision(node:Node3D):
	var prop_nodes = node.find_children("", "RigidBody3D") as Array[RigidBody3D]
	for child in prop_nodes:
		child.sleeping = true
		child.gravity_scale = 0.0
