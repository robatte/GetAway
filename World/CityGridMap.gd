@tool
extends GridMap

@export_category("Map")
@export var width = 10
@export var height = 10
@export var spacing = 2
@export var erase_fraction = 0.15
@export var Seed = 3

# bitwise walls: north, south, east, west
enum {N = 1, E = 2, S = 4, W = 8}

var cell_walls = {
	Vector3i(0, 0, -spacing): N,
	Vector3i(spacing, 0, 0): E,
	Vector3i(0, 0, spacing): S,
	Vector3i(-spacing, 0, 0): W
}

var plaza_tiles = [20, 22]

func _ready():
	if Seed != 0:
		seed(Seed)
	clear()
	if Engine.is_editor_hint():
		make_map_border()
		make_map()
		record_tile_position()
		
	if Network.local_player_id == 1:
		make_map_border()
		make_map()
		record_tile_position()
		rpc("send_ready")

func make_map_border():
	$Border.resize_border(cell_size.x, Vector2i(width, height))

func make_map():
	make_blank_map()
	make_maze()
	erase_walls()

func make_blank_map():
	for x in width:
		for z in height:
			var building = pick_building(x, z)
			const possible_rotations = [0, 10, 16, 22]
			var building_rotation = possible_rotations[randi() % possible_rotations.size() - 1]
			rpc("place_cell", Vector3i(x, 0, z), building, building_rotation)

func pick_building(x, z):
	const chance_of_skyscraper = 2
	const skyscraper = 16

	const neighbourhood_1 = [17, 18, 19] # Fabrics
	const neighbourhood_2 = [20, 21]	 # Homes
	const neighbourhood_3 = [22, 23, 24] # Shopping Malls
	const neighbourhood_4 = [25, 26, 27] # Car Sales
	
	var possible_buildings
	
	if x >= width / 2 and z >= height / 2: # South-East Quarter
		possible_buildings = neighbourhood_1
	elif x >= width / 2 and z < height / 2: # North-East Quarter
		possible_buildings = neighbourhood_3
	elif x < width / 2 and z >= height / 2: # South-West Quarter
		possible_buildings = neighbourhood_4
	else: 									# North-West Quarter
		possible_buildings = neighbourhood_2
	
	var building:int
	if (randi() % 99) + 1 <= chance_of_skyscraper:
		building = skyscraper
	else:
		building = possible_buildings[randi() % possible_buildings.size() - 1]
	return building
	
func check_neighbours(cell:Vector3i, unvisited):
	var list = []
	for n in cell_walls.keys():
		if cell + n in unvisited:
			list.append(cell + n)
	return list

func make_maze():
	var unvisited = []
	var stack = []
	
	# All cells are initially unvisted
	for x in range(0, width, spacing):
		for z in range(0, height, spacing):
			unvisited.append(Vector3i(x, 0, z))
	
	var current:Vector3i = Vector3i(0, 0, 0)
	unvisited.erase(current)
	
	while unvisited:
		var neighbours = check_neighbours(current, unvisited)
		
		if neighbours.size() > 0:
			stack.append(current)
			# For start use default next-position to guarantee a straight road
			var next:Vector3i
			if current == Vector3i(0, 0, 0):
				next = Vector3i(0, 0, spacing)
			else:
				next = neighbours[randi() % neighbours.size()]
			var direction:Vector3i = next - current
			
			# get tiletype-nr of a variation of the current tile without wall to next tile in direction. Reduced to Road tiles
			var current_walls = min(get_cell_item(current), 15) - cell_walls[direction]
			# get tiletype-nr of a variation of the next tile without wall to current tile in direction. Reduced to Road tiles
			var next_walls = min(get_cell_item(next), 15) - cell_walls[-direction]
			
			rpc("place_cell", current, current_walls)
			rpc("place_cell", next, next_walls)
			fill_gaps(current, direction)
			
			current = next
			unvisited.erase(current)
		elif stack:
			current = stack.pop_back()

func fill_gaps(current:Vector3i, direction:Vector3i):
	var tile_type
	for i in range(1, spacing):
		if direction.x > 0:
			tile_type = 5
			current.x += 1
		elif direction.x < 0:
			tile_type = 5
			current.x -= 1
		elif direction.z > 0:
			tile_type = 10
			current.z += 1
		elif direction.z < 0:
			tile_type = 10
			current.z -= 1
		rpc("place_cell", current, tile_type)

func erase_walls():
	# for some of the tiles:
	for i in range(width * height * erase_fraction):
		# get a random x, y thats not an edge tile
		var x = int(randf_range(1, (width - 1) / spacing)) * spacing
		var z = int(randf_range(1, (height - 1) / spacing)) * spacing
		var cell = Vector3i(x, 0, z)
		var current_cell = get_cell_item(cell)
		# get random direction
		var direction = cell_walls.keys()[randi() % cell_walls.size()]
		# bitwise check if there is a wall between th both
		if current_cell & cell_walls[direction]:
			# get wallfree( in direction) tile for current
			var walls = current_cell - cell_walls[direction]
			walls = clamp(walls, 0, 15)
			# get wallfree( in direction) tile for tile in direction
			var direction_walls = get_cell_item(cell + direction) - cell_walls[-direction]
			direction_walls = clamp(direction_walls, 0, 15)
			rpc("place_cell", cell, walls)
			rpc("place_cell", cell + direction, direction_walls)
			fill_gaps(cell, direction)

@rpc("any_peer", "call_local")
func place_cell(pos, tile, tile_rotation = 0):
	set_cell_item(pos, tile, tile_rotation)

func record_tile_position():
	var tiles = []
	var cafe_spots = []
	for x in range(0, width):
		for z in range(0, height):
			var current_cell = Vector3(x, 0, z)
			var current_tile_type = get_cell_item(current_cell)
			if current_tile_type < 15:
				tiles.append(current_cell)
			elif current_tile_type in plaza_tiles:
				var building_rotation = get_cell_item_orientation(current_cell)
				var plaza_location = [building_rotation, x, z]
				cafe_spots.append(plaza_location)
	var map_size = Vector2(width, height)
	$ObjectSpawner.generate_props(tiles, map_size, cafe_spots)
			


### GameState ###
@rpc("any_peer", "call_local")
func send_ready():
	if Network.local_player_id == 1:
		player_ready()
	else:
		rpc_id(1, "player_ready")
	
@rpc("any_peer")
func player_ready():
	Network.ready_players += 1
	if Network.ready_players == Network.players.size():
		rpc("send_go")
	
@rpc("any_peer", "call_local")
func send_go():
	get_tree().call_group("GameState", "unpause")
