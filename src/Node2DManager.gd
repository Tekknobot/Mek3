extends Node2D

const N = 0x1
const E = 0x2
const S = 0x4
const W = 0x8

var cell_walls = {Vector2i(0, -1): N, Vector2i(1, 0): E,
				  Vector2i(0, 1): S, Vector2i(-1, 0): W}

var moves = {N: Vector2i(0, -1),
			 S: Vector2i(0, 1),
			 E: Vector2i(1, 0),
			 W: Vector2i(-1, 0)}
			
@onready var Map = $TileMap

var map_pos = Vector2(0,0)
var rng = RandomNumberGenerator.new()
var tile_id
var fastNoiseLite = FastNoiseLite.new()
var grid = []

# Called when the node enters the scene tree for the first time.
func _ready():
	generate_world()																			

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass	

func _input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_1:
			get_tree().reload_current_scene()		
		if event.pressed and event.keycode == KEY_2:
			generate_world()																	

func move(dir):
	map_pos += moves[dir]
	if map_pos.x >= 0 and map_pos.x <= 15 and map_pos.y >= 0 and map_pos.y <= 15:
		generate_tile(map_pos)
	
func generate_tile(cell):
		var _cells = find_valid_tiles(cell)
		Map.set_cell(0, map_pos, -1, Vector2i(0, 0), 0)
		Map.set_cell(0, map_pos, tile_id, Vector2i(0, 0), 0)
		
func find_valid_tiles(cell):
	var valid_tiles = []
	# check all possible tiles, 0 - 15
	for i in range(16):
		# check the target space's neighbors (if they exist)
		var is_match = false
		for n in cell_walls.keys():		
			var neighbor_id = Map.get_cell_source_id(0, cell + n, false)
			if neighbor_id >= 0:
				# id == -1 is a blank tile
				if (neighbor_id & cell_walls[-n])/cell_walls[-n] == (i & cell_walls[n])/cell_walls[n]:
					is_match = true
				else:
					is_match = false
					# if we found a mismatch, we don't need to check the remaining sides
					break
		if is_match and not i in valid_tiles:
			valid_tiles.append(i)
	return valid_tiles
	
func generate_world():
	# A random number generator which we will use for the noise seed
	var tilelist = [0, 1, 2, 3, 4, 5]
	
	#var rng = RandomNumberGenerator.new()
	fastNoiseLite.seed = rng.randi_range(0, 256)
	fastNoiseLite.TYPE_PERLIN
	fastNoiseLite.fractal_octaves = tilelist.size()
	fastNoiseLite.fractal_gain = 0
	
	for x in get_node("TileMap").grid_width:
		grid.append([])
		for y in get_node("TileMap").grid_height:
			grid[x].append(0)
			# We get the noise coordinate as an absolute value (which represents the gradient - or layer)	
			var absNoise = abs(fastNoiseLite.get_noise_2d(x,y))
			var tiletoplace = int(floor((absNoise * tilelist.size())))
			Map.set_cell(0, Vector2i(x,y), tilelist[tiletoplace], Vector2i(0, 0), 0)
	
	generate_roads_and_tiles()
			
			
func generate_roads_and_tiles():
	var tile_random_id = rng.randi_range(3, 5)
	# Tiles
	for h in get_node("TileMap").structureArray.size():
		var structure_group = get_tree().get_nodes_in_group("structure")
		var structure_global_pos = structure_group[h].position
		var structure_pos = Map.local_to_map(structure_global_pos)
		map_pos = structure_pos
		
		for i in 8:
			tile_id = tile_random_id
			var size = moves.size()
			var random_key = moves.keys()[randi() % size]					
			move(random_key)
		map_pos = structure_pos
		for i in 8:
			tile_id = tile_random_id
			var size = moves.size()
			var random_key = moves.keys()[randi() % size]					
			move(random_key)
		map_pos = structure_pos
		for i in 8:
			tile_id = tile_random_id
			var size = moves.size()
			var random_key = moves.keys()[randi() % size]					
			move(random_key)
		map_pos = structure_pos
		for i in 8:
			tile_id = tile_random_id
			var size = moves.size()
			var random_key = moves.keys()[randi() % size]					
			move(random_key)	
			
	# Roads		
	for h in 2:
		var structure_group = get_tree().get_nodes_in_group("structure")
		var structure_global_pos = structure_group[h].position
		var structure_pos = Map.local_to_map(structure_global_pos)
		map_pos = structure_pos
				
		for i in 15:
			tile_id = 42
			move(E)
		map_pos = structure_pos	
		for i in 15:
			tile_id = 41
			move(S)
		map_pos = structure_pos
		for i in 15:
			tile_id = 42
			move(W)
		map_pos = structure_pos
		for i in 15:
			tile_id = 41
			move(N)	
					
		# Intersection		
		for i in 16:
			for j in 16:
				if Map.get_cell_source_id(0, Vector2i(i,j)) == 41:
					var surrounding_cells = Map.get_surrounding_cells(Vector2i(i,j))
					for k in 4:
						if Map.get_cell_source_id(0, surrounding_cells[0]) == 42 and Map.get_cell_source_id(0, surrounding_cells[1]) == 41 and Map.get_cell_source_id(0, surrounding_cells[2]) == 42 and Map.get_cell_source_id(0, surrounding_cells[3]) == 41:
							Map.set_cell(0, Vector2i(i,j), 43, Vector2i(0, 0), 0)														
			
		for i in 16:
			for j in 16:
				if Map.get_cell_source_id(0, Vector2i(i,j)) == 42:
					var surrounding_cells = Map.get_surrounding_cells(Vector2i(i,j))
					for k in 4:
						if Map.get_cell_source_id(0, surrounding_cells[0]) == 42 and Map.get_cell_source_id(0, surrounding_cells[1]) == 41 and Map.get_cell_source_id(0, surrounding_cells[2]) == 42 and Map.get_cell_source_id(0, surrounding_cells[3]) == 41:
							Map.set_cell(0, Vector2i(i,j), 43, Vector2i(0, 0), 0)			
			
			
			
			
