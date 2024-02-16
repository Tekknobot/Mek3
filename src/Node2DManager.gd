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
@export var hovertile: Sprite2D
@export var arrow: Area2D
@export var structureCoord: Array[Vector2i]
@export var mapbutton: Button
@export var spawnbutton: Button

var map_pos = Vector2(0,0)
var road_pos = Vector2(0,0)
var rng = RandomNumberGenerator.new()
var tile_id
var fastNoiseLite = FastNoiseLite.new()
var grid = []

var grid_width = 16
var grid_height = 16

var building = preload("res://scenes/building_c.scn")
var tower = preload("res://scenes/tower.scn")
var stadium = preload("res://scenes/stadium.scn")
var district = preload("res://scenes/district.scn")

var structures: Array[Area2D]
var buildings = []
var towers = []
var stadiums = []
var districts = []

var world = false
var mars = false
var moon = false

var tile_num = 4

# Called when the node enters the scene tree for the first time.
func _ready():	
	select_biome()	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):	
	pass
	
# Called when the node enters the scene tree for the first time.
func spawn_structures():	
	# Randomize structures at start	
	for i in 16: #buildings
		var my_random_tile_x = rng.randi_range(1, 14)
		var my_random_tile_y = rng.randi_range(1, 14)
		var tile_pos = Vector2i(my_random_tile_x, my_random_tile_y)
		var tile_center_pos = Map.map_to_local(tile_pos) + Vector2(0,0) / 2		
		var building_inst = building.instantiate()
		building_inst.position = tile_center_pos
		add_child(building_inst)
		building_inst.add_to_group("buildings")		
		building_inst.z_index = tile_pos.x + tile_pos.y
		building_inst.get_child(0).modulate = Color8(rng.randi_range(150, 255), rng.randi_range(150, 255), rng.randi_range(150, 255))	
		building_inst.position = Vector2(tile_center_pos.x, tile_center_pos.y-500)						
		var tween: Tween = create_tween()
		tween.tween_property(building_inst, "position", tile_center_pos, 1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)				
		await get_tree().create_timer(0.1).timeout
		
	for i in 3: #stadiums
		var my_random_tile_x = rng.randi_range(1, 14)
		var my_random_tile_y = rng.randi_range(1, 14)
		var tile_pos = Vector2i(my_random_tile_x, my_random_tile_y)
		var tile_center_pos = Map.map_to_local(tile_pos) + Vector2(0,0) / 2		
		var stadium_inst = stadium.instantiate()
		stadium_inst.position = tile_center_pos
		add_child(stadium_inst)	
		stadium_inst.add_to_group("stadiums")	
		stadium_inst.z_index = tile_pos.x + tile_pos.y
		stadium_inst.get_child(0).modulate = Color8(rng.randi_range(150, 255), rng.randi_range(150, 255), rng.randi_range(150, 255))		
		stadium_inst.position = Vector2(tile_center_pos.x, tile_center_pos.y-500)						
		var tween: Tween = create_tween()
		tween.tween_property(stadium_inst, "position", tile_center_pos, 1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)				
		await get_tree().create_timer(0.1).timeout
			
	for i in 3: #districts
		var my_random_tile_x = rng.randi_range(1, 14)
		var my_random_tile_y = rng.randi_range(1, 14)
		var tile_pos = Vector2i(my_random_tile_x, my_random_tile_y)
		var tile_center_pos = Map.map_to_local(tile_pos) + Vector2(0,0) / 2		
		var district_inst = district.instantiate()
		district_inst.position = tile_center_pos
		add_child(district_inst)
		district_inst.add_to_group("districts")		
		district_inst.z_index = tile_pos.x + tile_pos.y				
		district_inst.get_child(0).modulate = Color8(rng.randi_range(150, 255), rng.randi_range(150, 255), rng.randi_range(150, 255))		
		district_inst.position = Vector2(tile_center_pos.x, tile_center_pos.y-500)						
		var tween: Tween = create_tween()
		tween.tween_property(district_inst, "position", tile_center_pos, 1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)				
		await get_tree().create_timer(0.1).timeout
			
					
	buildings = get_tree().get_nodes_in_group("buildings")
	towers = get_tree().get_nodes_in_group("towers")
	stadiums = get_tree().get_nodes_in_group("stadiums")
	districts = get_tree().get_nodes_in_group("districts")
	
	structures.append_array(buildings)
	structures.append_array(towers)
	structures.append_array(stadiums)
	structures.append_array(districts)
	
	check_duplicates(structures)
		
	var my_random_tile_x = get_random_numbers(1, 14)
	var my_random_tile_y = get_random_numbers(1, 14)				
	for i in 3: #towers
		var tile_pos = Vector2i(my_random_tile_x[i], my_random_tile_y[i])
		var tile_center_pos = Map.map_to_local(tile_pos) + Vector2(0,0) / 2		
		var tower_inst = tower.instantiate()
		tower_inst.position = tile_center_pos
		add_child(tower_inst)	
		tower_inst.add_to_group("towers")	
		tower_inst.z_index = tile_pos.x + tile_pos.y
		tower_inst.get_child(0).modulate = Color8(rng.randi_range(150, 255), rng.randi_range(150, 255), rng.randi_range(150, 255))		
		#arrow.position = Vector2(tile_center_pos.x-5, tile_center_pos.y-109) 
		#arrow.z_index = 100

func spawn_towers():	
	towers = get_tree().get_nodes_in_group("towers")
	structures.append_array(towers)			
	check_duplicates(structures)	
	await get_tree().create_timer(1).timeout

func select_biome():	
	var biome = rng.randi_range(0, 2)	
	if biome == 0:		
		generate_world()
		world = true
	if biome == 1:		
		generate_mars()
		mars = true
	if biome == 2:		
		generate_moon()	
		moon = true																				
	
func _input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_1:
			#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)			
			#get_tree().reload_current_scene()	
			pass	
			
		if event.pressed and event.keycode == KEY_2:
			pass															

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
	
	#var rng = RandomNumberGenerator.new()zz
	fastNoiseLite.seed = rng.randi_range(0, 256)
	fastNoiseLite.TYPE_PERLIN
	fastNoiseLite.fractal_octaves = tilelist.size()
	fastNoiseLite.fractal_gain = 0
	
	for x in grid_width:
		grid.append([])
		await get_tree().create_timer(0.1).timeout
		for y in grid_height:
			grid[x].append(0)
			# We get the noise coordinate as an absolute value (which represents the gradient - or layer)	
			var absNoise = abs(fastNoiseLite.get_noise_2d(x,y))
			var tiletoplace = int(floor((absNoise * tilelist.size())))
			Map.set_cell(0, Vector2i(x,y), tilelist[tiletoplace], Vector2i(0, 0), 0)
			
		
	_on_map_pressed()
			
func generate_mars():
	# A random number generator which we will use for the noise seed
	var tilelist = [49, 50, 51, 52, 53, 54]
	
	#var rng = RandomNumberGenerator.new()zz
	fastNoiseLite.seed = rng.randi_range(0, 256)
	fastNoiseLite.TYPE_PERLIN
	fastNoiseLite.fractal_octaves = tilelist.size()
	fastNoiseLite.fractal_gain = 0
	
	for x in grid_width:
		grid.append([])
		await get_tree().create_timer(0.1).timeout
		for y in grid_height:
			grid[x].append(0)
			# We get the noise coordinate as an absolute value (which represents the gradient - or layer)	
			var absNoise = abs(fastNoiseLite.get_noise_2d(x,y))
			var tiletoplace = int(floor((absNoise * tilelist.size())))
			Map.set_cell(0, Vector2i(x,y), tilelist[tiletoplace], Vector2i(0, 0), 0)
			
	
	_on_map_pressed()

func generate_moon():
	# A random number generator which we will use for the noise seed
	var tilelist = [55, 56, 57, 58, 59, 60]
	
	#var rng = RandomNumberGenerator.new()zz
	fastNoiseLite.seed = rng.randi_range(0, 256)
	fastNoiseLite.TYPE_PERLIN
	fastNoiseLite.fractal_octaves = tilelist.size()
	fastNoiseLite.fractal_gain = 0
	
	for x in grid_width:
		grid.append([])
		await get_tree().create_timer(0.1).timeout
		for y in grid_height:
			grid[x].append(0)
			# We get the noise coordinate as an absolute value (which represents the gradient - or layer)	
			var absNoise = abs(fastNoiseLite.get_noise_2d(x,y))
			var tiletoplace = int(floor((absNoise * tilelist.size())))
			Map.set_cell(0, Vector2i(x,y), tilelist[tiletoplace], Vector2i(0, 0), 0)
	
	_on_map_pressed()
			
func generate_roads_and_tiles():
	var tile_random_id = rng.randi_range(3, 5)
	# Tiles
	for h in structures.size():
		var structure_group = get_tree().get_nodes_in_group("structure")
		var structure_global_pos = structure_group[h].position
		var structure_pos = Map.local_to_map(structure_global_pos)
		map_pos = structure_pos
		
		for i in tile_num:
			tile_id = tile_random_id
			var size = moves.size()
			var random_key = moves.keys()[randi() % size]					
			move(random_key)
			await get_tree().create_timer(0).timeout
		map_pos = structure_pos
		for i in tile_num:
			tile_id = tile_random_id
			var size = moves.size()
			var random_key = moves.keys()[randi() % size]					
			move(random_key)
			await get_tree().create_timer(0).timeout
		map_pos = structure_pos
		for i in tile_num:
			tile_id = tile_random_id
			var size = moves.size()
			var random_key = moves.keys()[randi() % size]					
			move(random_key)
			await get_tree().create_timer(0).timeout
		map_pos = structure_pos
		for i in tile_num:
			tile_id = tile_random_id
			var size = moves.size()
			var random_key = moves.keys()[randi() % size]					
			move(random_key)	
			await get_tree().create_timer(0).timeout
	
	await spawn_towers()			
	
func generate_roads_and_tiles_mars():
	var tile_random_id = rng.randi_range(52, 54)
	# Tiles
	for h in structures.size():
		var structure_group = get_tree().get_nodes_in_group("structure")
		var structure_global_pos = structure_group[h].position
		var structure_pos = Map.local_to_map(structure_global_pos)
		map_pos = structure_pos
		
		for i in tile_num:
			tile_id = tile_random_id
			var size = moves.size()
			var random_key = moves.keys()[randi() % size]					
			move(random_key)
			await get_tree().create_timer(0).timeout
		map_pos = structure_pos
		for i in tile_num:
			tile_id = tile_random_id
			var size = moves.size()
			var random_key = moves.keys()[randi() % size]					
			move(random_key)
			await get_tree().create_timer(0).timeout
		map_pos = structure_pos
		for i in tile_num:
			tile_id = tile_random_id
			var size = moves.size()
			var random_key = moves.keys()[randi() % size]					
			move(random_key)
			await get_tree().create_timer(0).timeout
		map_pos = structure_pos
		for i in tile_num:
			tile_id = tile_random_id
			var size = moves.size()
			var random_key = moves.keys()[randi() % size]					
			move(random_key)	
			await get_tree().create_timer(0).timeout

	await spawn_towers()

func generate_roads_and_tiles_moon():
	var tile_random_id = rng.randi_range(58, 60)
	# Tiles
	for h in structures.size():
		var structure_group = get_tree().get_nodes_in_group("structure")
		var structure_global_pos = structure_group[h].position
		var structure_pos = Map.local_to_map(structure_global_pos)
		map_pos = structure_pos
		
		for i in tile_num:
			tile_id = tile_random_id
			var size = moves.size()
			var random_key = moves.keys()[randi() % size]					
			move(random_key)
			await get_tree().create_timer(0).timeout
		map_pos = structure_pos
		for i in tile_num:
			tile_id = tile_random_id
			var size = moves.size()
			var random_key = moves.keys()[randi() % size]					
			move(random_key)
			await get_tree().create_timer(0).timeout
		map_pos = structure_pos
		for i in tile_num:
			tile_id = tile_random_id
			var size = moves.size()
			var random_key = moves.keys()[randi() % size]					
			move(random_key)
			await get_tree().create_timer(0).timeout
		map_pos = structure_pos
		for i in tile_num:
			tile_id = tile_random_id
			var size = moves.size()
			var random_key = moves.keys()[randi() % size]					
			move(random_key)	
			await get_tree().create_timer(0).timeout
	
	await spawn_towers()

func generate_roads():				
	# Roads		
	for h in 3:
		var structure_group = get_tree().get_nodes_in_group("towers")
		var structure_global_pos = structure_group[h].position
		var structure_pos = Map.local_to_map(structure_global_pos)
		map_pos = structure_pos
				
		for i in grid_width:
			tile_id = 42
			move(E)
			await get_tree().create_timer(0.01).timeout
		map_pos = structure_pos	
		for i in grid_width:
			tile_id = 41
			move(S)
			await get_tree().create_timer(0.01).timeout
		map_pos = structure_pos
		for i in grid_width:
			tile_id = 42
			move(W)
			await get_tree().create_timer(0.01).timeout
		map_pos = structure_pos
		for i in grid_width:
			tile_id = 41
			move(N)	
			await get_tree().create_timer(0.01).timeout
					
		# Intersection		
		for i in grid_width:
			for j in grid_height:
				if Map.get_cell_source_id(0, Vector2i(i,j)) == 41:
					var surrounding_cells = Map.get_surrounding_cells(Vector2i(i,j))
					for k in 4:
						if Map.get_cell_source_id(0, surrounding_cells[0]) == 42 and Map.get_cell_source_id(0, surrounding_cells[1]) == 41 and Map.get_cell_source_id(0, surrounding_cells[2]) == 42 and Map.get_cell_source_id(0, surrounding_cells[3]) == 41:
							Map.set_cell(0, Vector2i(i,j), 43, Vector2i(0, 0), 0)														
			
		for i in grid_width:
			for j in grid_height:
				if Map.get_cell_source_id(0, Vector2i(i,j)) == 42:
					var surrounding_cells = Map.get_surrounding_cells(Vector2i(i,j))
					for k in 4:
						if Map.get_cell_source_id(0, surrounding_cells[0]) == 42 and Map.get_cell_source_id(0, surrounding_cells[1]) == 41 and Map.get_cell_source_id(0, surrounding_cells[2]) == 42 and Map.get_cell_source_id(0, surrounding_cells[3]) == 41:
							Map.set_cell(0, Vector2i(i,j), 43, Vector2i(0, 0), 0)			
			
func check_duplicates(a):
	var is_dupe = false
	var found_dupe = false 

	for i in range(a.size()):
		if is_dupe == true:
			break
		for j in range(a.size()):
			if a[j].position == a[i].position && i != j:
				#is_dupe = true
				found_dupe = true
				#print("duplicate")
				var j_pos = Map.local_to_map(a[j].position)	
				var j_global = Map.map_to_local(Vector2i(j_pos.x, j_pos.y)) + Vector2(0,0) / 2	
				a[j].position = j_global
				var tile_pos_j = Vector2i(j_pos.x, j_pos.y)
				a[j].get_child(0).modulate = Color8(0, 0, 0)
				a[j].get_child(0).modulate.a = 0	
				a[j].z_index = (tile_pos_j.x + tile_pos_j.y) - (tile_pos_j.x + tile_pos_j.y) - 100

				var i_pos = Map.local_to_map(a[i].position)	
				var i_global = Map.map_to_local(Vector2i(i_pos.x, i_pos.y)) + Vector2(0,0) / 2	
				a[i].position = i_global
				var tile_pos_i = Vector2i(i_pos.x, i_pos.y)
				a[i].get_child(0).modulate = Color8(255, 255, 255)	
				a[i].z_index = tile_pos_i.x + tile_pos_i.y
							
func reload_scene():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)			
	get_tree().reload_current_scene()				

func _on_map_pressed():
	mapbutton.hide()
	spawnbutton.show()
		
	if world == true:
		await spawn_structures()
		await generate_roads_and_tiles()		
		generate_roads()
	if mars == true:
		await spawn_structures()
		await generate_roads_and_tiles_mars()		
		generate_roads()	
	if moon == true:
		await spawn_structures()
		await generate_roads_and_tiles_moon()	
		generate_roads()	
	
	hovertile.show()	

	
func get_random_numbers(from, to):
	var arr = []
	for i in range(from,to):
		arr.append(i)
	arr.shuffle()
	return arr	
