@tool
extends Node3D

func resize_border(tile_size:int, tile_count:Vector2i):
	rpc("make_border", tile_size,  tile_count)
	
@rpc("any_peer", "call_local")
func make_border(tile_size:int,  tile_count:Vector2i):
	var wall_size = Vector2(tile_size * tile_count.x, tile_size * tile_count.y)
	$N_Wall.position = Vector3(wall_size.x / 2, $N_Wall.size.y / 2, -.5)
	$N_Wall.size.x = wall_size.x + 2
	
	$S_Wall.position = Vector3(wall_size.x / 2, $S_Wall.size.y / 2, wall_size.y + .5)
	$S_Wall.size.x = wall_size.x + 2
	
	$W_Wall.position = Vector3(-.5, $W_Wall.size.y / 2, wall_size.y / 2)
	$W_Wall.size.x = wall_size.y + 2
	
	$E_Wall.position = Vector3(wall_size.x + .5, $E_Wall.size.y / 2, wall_size.y / 2)
	$E_Wall.size.x = wall_size.y + 2
	
	for child in get_children():
		child.use_collision = false
		child.use_collision = true
