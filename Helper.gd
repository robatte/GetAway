@tool
extends Node

var escape = PackedByteArray([0x1b]).get_string_from_ascii()

func fade_out(node, time = 3):
	var TW = create_tween().set_parallel()
	for obj in node.find_children("", "GeometryInstance3D"):
		TW.tween_property(obj, "transparency", 1.0, time)
	return await TW.finished

func activate_collision(node:Node3D):
	var prop_nodes = node.find_children("", "RigidBody3D") as Array[RigidBody3D]
	for child in prop_nodes:
		child.sleeping = true
		child.gravity_scale = 1.0
		
func deactivate_collision(node:Node3D):
	var prop_nodes = node.find_children("", "RigidBody3D") as Array[RigidBody3D]
	for child in prop_nodes:
		child.sleeping = true
		child.gravity_scale = 0.0

func Log(caller:String, msg:String):
	print_rich("[color=green][" + caller + ":" + str(Network.local_player_id) +"]:[/color]" + msg)
	get_tree().call_group("Console", "console_log", "[" + caller + ":" + str(Network.local_player_id) +"]:" + msg)

func LogA(caller:String, msgA:Array):
	print_rich("[color=green][" + caller + ":" + str(Network.local_player_id) +"]:[/color]")
	for n in msgA:
		print_rich("[indent] - " + str(n) + "[/indent]")
		
func notify(text: String, time = 6):
	get_tree().call_group("Notifications", "notify", text, time)
