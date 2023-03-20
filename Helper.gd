@tool
extends Node

func fade_out(node, time = 3):
	var TW = create_tween().set_parallel()
	for obj in node.find_children("", "GeometryInstance3D"):
		TW.tween_property(obj, "transparency", 1.0, time)
	return await TW.finished
