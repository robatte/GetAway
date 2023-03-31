@tool
extends Node

var tiles = [] 
var cafe_spots = []
var map_size = Vector2()

const tile_size = 20

func generate_props(tile_list, size:Vector2, plazas):
	tiles = tile_list
	map_size = size
	cafe_spots = plazas
	
	var tile_list_of_Beacons = random_tile(Config.Props[Config.Beacons].number_of + Config.Props[Config.Goal].number_of)
	var tile_list_of_Scaffoldings = random_tile(Config.Props[Config.Scaffoldings].number_of)
	var tile_list_of_Billboards = random_tile(Config.Props[Config.Billboards].number_of)
	var tile_list_of_TrafficCones = random_tile(Config.Props[Config.TrafficCones].number_of)
	var tile_list_of_Cafes = random_tile(Config.Props[Config.Cafes].number_of)
	var tile_list_of_Cars_and_Ramps = random_tile(Config.Props[Config.ParkedCars].number_of + Config.Props[Config.Dumpsters].number_of)
	var tile_list_of_Hydrants_and_Lights = random_tile(Config.Props[Config.Hydrants].number_of + Config.Props[Config.StreeLights].number_of)
	
	Config.Props[Config.Goal].tiles_list = tile_list_of_Beacons
	Config.Props[Config.Beacons].tiles_list = tile_list_of_Beacons
	Config.Props[Config.Scaffoldings].tiles_list = tile_list_of_Scaffoldings
	Config.Props[Config.ParkedCars].tiles_list = tile_list_of_Cars_and_Ramps
	Config.Props[Config.Dumpsters].tiles_list = tile_list_of_Cars_and_Ramps
	Config.Props[Config.Billboards].tiles_list = tile_list_of_Billboards
	Config.Props[Config.TrafficCones].tiles_list = tile_list_of_TrafficCones
	Config.Props[Config.StreeLights].tiles_list = tile_list_of_Hydrants_and_Lights
	Config.Props[Config.Hydrants].tiles_list = tile_list_of_Hydrants_and_Lights
	Config.Props[Config.Cafes].tiles_list = tile_list_of_Cafes
	
	place_props(Config.Beacons)
	place_props(Config.Goal)
	place_props(Config.Scaffoldings)
	place_props(Config.ParkedCars)
	place_props(Config.Dumpsters)
	place_props(Config.Billboards)
	place_props(Config.TrafficCones)
	place_props(Config.StreeLights)
	place_props(Config.Hydrants)
	place_cafes()
	
func random_tile(tile_count) -> Array[Vector3] :
	var tile_list = tiles
	var selected_tiles:Array[Vector3] = []
	tile_list.shuffle()
	for i in range(min(tile_count, tile_list.size())):
		var tile = tile_list[i]
		selected_tiles.append(tile)
	return selected_tiles
	
func place_props(PropType):
	for i in range(min(Config.Props[PropType].number_of, Config.Props[PropType].tiles_list.size())):
		var tile = Config.Props[PropType].tiles_list[0]
		var tile_type = get_parent().get_cell_item(tile)
		var allowed_rotations = $ObjectRotationLookup.lookup_rotation(tile_type)
		if not allowed_rotations == null:
			var tile_rotation = allowed_rotations[randi() % allowed_rotations.size()] * -1
			tile.y += .19
			rpc("spawn_prop", PropType, tile, tile_rotation)
		Config.Props[PropType].tiles_list.pop_front()
		
func place_cafes():
	cafe_spots.shuffle()
	for i in range(min(Config.Props[Config.Cafes].number_of, cafe_spots.size())):
		var cafe = cafe_spots[i]
		var building_rotation = cafe[0]
		var cafe_position = Vector3(cafe[1], 0, cafe[2])
		var cafe_rotation = 0
		if building_rotation == 10:
			cafe_rotation = 180
		elif building_rotation == 16:
			cafe_rotation = 90
		elif building_rotation == 22:
			cafe_rotation = 270
		rpc("spawn_prop", Config.Cafes, cafe_position, cafe_rotation)
		
@rpc("any_peer", "call_local")
func spawn_prop(PropsType, tile, prop_rotation):
	var prop = Config.Props[PropsType].scene.instantiate()			
	prop.position = Vector3((tile.x * tile_size) + tile_size / 2.0, tile.y, (tile.z * tile_size) + tile_size / 2.0)
	prop.rotation_degrees.y = prop_rotation
	add_child(prop, true)

