@tool
extends Node

var tiles = [] 
var cafe_spots = []
var map_size = Vector2()

const tile_size = 20

const number_of_parked_cars = 100
const number_of_billboards = 75
const number_of_traffic_cones = 40
const number_of_hydrants = 50
const number_of_street_lights = 50
const number_of_ramps = 25
const number_of_scaffolding = 25
const number_of_cafes = 20

var scene_Scaffolding:Resource = preload("res://Props/Scaffolding/Scaffolding.tscn")
var scene_ParkedCars:Resource = preload("res://Props/ParkedCars/ParkedCars.tscn")
var scene_Dumpsters:Resource = preload("res://Props/Dumpsters/Dumpster.tscn")
var scene_Billboards:Resource = preload("res://Props/Billboards/Billboard.tscn")
var scene_TrafficCones:Resource = preload("res://Props/TrafficCones/traffic_cone.tscn")
var scene_StreeLights:Resource = preload("res://Props/StreeLights/StreetLight.tscn")
var scene_Hydrants:Resource = preload("res://Props/Hydrants/Hydrant.tscn")
var scene_Cafes:Resource = preload("res://Props/Cafe/Cafe.tscn")

func generate_props(tile_list, size:Vector2, plazas):
	tiles = tile_list
	map_size = size
	cafe_spots = plazas
	
	var tile_list_of_cars_and_ramps = random_tile(number_of_parked_cars + number_of_ramps)
	var tile_list_of_billboards = random_tile(number_of_billboards)
	var tile_list_of_traffic_cones = random_tile(number_of_traffic_cones)
	var tile_list_of_hydrants_and_lights = random_tile(number_of_hydrants + number_of_street_lights)
	var tile_list_of_scaffolding = random_tile(number_of_scaffolding)
	
	place_props(scene_Scaffolding, number_of_scaffolding, tile_list_of_scaffolding)
	place_props(scene_ParkedCars, number_of_parked_cars, tile_list_of_cars_and_ramps)
	place_props(scene_Dumpsters, number_of_ramps, tile_list_of_cars_and_ramps)
	place_props(scene_Billboards, number_of_billboards, tile_list_of_billboards)
	place_props(scene_TrafficCones, number_of_traffic_cones, tile_list_of_traffic_cones)
	place_props(scene_StreeLights, number_of_street_lights, tile_list_of_hydrants_and_lights)
	place_props(scene_Hydrants, number_of_hydrants, tile_list_of_hydrants_and_lights)
	place_cafes()
	
func random_tile(tile_count) -> Array[Vector3] :
	var tile_list = tiles
	var selected_tiles:Array[Vector3] = []
	tile_list.shuffle()
	for i in range(min(tile_count, tile_list.size())):
		var tile = tile_list[i]
		selected_tiles.append(tile)
	return selected_tiles
	
func place_props(scene:Resource, number_of_props:int, tiles_list):
	for i in range(min(number_of_props, tiles_list.size())):
		var tile = tiles_list[0]
		var tile_type = get_parent().get_cell_item(tile)
		var allowed_rotations = $ObjectRotationLookup.lookup_rotation(tile_type)
		if not allowed_rotations == null:
			var tile_rotation = allowed_rotations[randi() % allowed_rotations.size()] * -1
			tile.y += .19
			rpc("spawn_prop", scene, tile, tile_rotation)
		tiles_list.pop_front()
		
func place_cafes():
	cafe_spots.shuffle()
	for i in range(min(number_of_cafes, cafe_spots.size())):
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
		rpc("spawn_prop", scene_Cafes, cafe_position, cafe_rotation)
		
@rpc("any_peer", "call_local")
func spawn_prop(scene:Resource, tile, prop_rotation):
	var prop = scene.instantiate()			
	prop.position = Vector3((tile.x * tile_size) + tile_size / 2.0, tile.y, (tile.z * tile_size) + tile_size / 2.0)
	prop.rotation_degrees.y = prop_rotation
	add_child(prop, true)
	
