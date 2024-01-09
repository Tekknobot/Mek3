extends TileMap

var grid = []
var grid_width = 16
var grid_height = 16

var rng = RandomNumberGenerator.new()

var totalunits = 10
var totalstructures = 12
var totaltiles = 256

@export var camera: Camera2D

@export var unitsAnimated2D: Array[AnimatedSprite2D]
@export var unitsArray: Array[Area2D] 
@export var structureArray: Array[Area2D]
@export var unitsCoord: Array[Vector2i]

@export var unitsCoord_1: Array[Vector2i]
@export var unitsCoord_2: Array[Vector2i]

@export var tileCoord: Array[Vector2i]
@export var structureCoord: Array[Vector2i]

@export var hovertile: Sprite2D

var tile_pos_center = Vector2i(0,0)
var tile_pos_left = Vector2i(0,0)
var tile_pos_right = Vector2i(0,0)
var tile_pos_front = Vector2i(0,0)
var tile_pos_back = Vector2i(0,0)

var tile_pos_left_array = []
var tile_pos_right_array = []
var tile_pos_front_array = []
var tile_pos_back_array = []

var astar_grid = AStarGrid2D.new()
var clicked_pos = Vector2i(0,0);
var dropped_pos = Vector2i(0,0);

var moving = false
@export var clicked_unit: int = 0
@export var right_clicked_unit: int
@export var unit_type: String

signal unit_used_turn

@export var only_once : bool = true
@export var only_once_structures : bool = true

@export var map_sfx: Array[AudioStream]

var hovertile_type = 48
var hovered_unit

var moves_counter = 0;

var structures: Array[Area2D]
var buildings = []
var towers = []
var stadiums = []
var districts = []

# Called when the node enters the scene tree for the first time.
func _ready():	
	randomize()
	get_node("../BattleManager").available_units.shuffle()
	
	# Randomize units at start		
	for i in get_node("../BattleManager").available_units.size():
		while true:
			var my_random_tile_x = rng.randi_range(1, 14)
			var my_random_tile_y = rng.randi_range(1, 14)
			var tile_pos = Vector2i(my_random_tile_x, my_random_tile_y)
			var tile_center_pos = map_to_local(tile_pos) + Vector2(0,0) / 2
			var ontile = false
			for j in get_node("../BattleManager").available_units.size():
				if j != i and unitsCoord[j] == tile_pos or unitsCoord[j].x == tile_pos.x + 1 or unitsCoord[j].x == tile_pos.x - 1 or unitsCoord[j].y == tile_pos.y + 1 or unitsCoord[j].y == tile_pos.y - 1:
					ontile = true
			if !ontile:
				unitsCoord[i] = tile_pos
				get_node("../BattleManager").available_units[i].position = tile_center_pos
				get_node("../BattleManager").available_units[i].z_index = tile_pos.x + tile_pos.y
				get_node("../BattleManager").available_units[i].unit_team = 1
				if i > 4:
					get_node("../BattleManager").available_units[i].unit_team = 2	
					
				break
	
	# Check if units are on structures
	for i in get_node("../BattleManager").available_units.size():
		for j in structureCoord.size():
			if unitsCoord[i] == structureCoord[j]:
				var tile_pos = Vector2i(unitsCoord[i].x+1, unitsCoord[i].y+1)
				var tile_center_pos = map_to_local(tile_pos) + Vector2(0,0) / 2	
				unitsCoord[i] = tile_pos
				get_node("../BattleManager").available_units[i].position = tile_center_pos
				get_node("../BattleManager").available_units[i].z_index = tile_pos.x + tile_pos.y		
							
		
# Called every frame. 'delta' is the elapsed time since the previous frame..
func _process(_delta):
	# Tile hover
	var mouse_pos = get_global_mouse_position()
	var tile_pos = local_to_map(mouse_pos)
	var tile_center_pos = map_to_local(tile_pos) + Vector2(0,0) / 2

	var tile_data = get_cell_tile_data(0, tile_pos)

	if tile_data is TileData:					
		hovertile.position = tile_center_pos
		hovertile.z_index = tile_pos.x + tile_pos.y
		#print(tile_pos);
		for i in get_node("../BattleManager").team_1.size():
			if tile_pos == unitsCoord_1[i]:		
				hovered_unit = i
		for i in get_node("../BattleManager").team_2.size():
			if tile_pos == unitsCoord_2[i]:		
				hovered_unit = i

	astar_grid.size = Vector2i(16, 16)
	astar_grid.cell_size = Vector2(1, 1)
	astar_grid.default_compute_heuristic = 1
	astar_grid.diagonal_mode = 1
	astar_grid.update()

	buildings = get_tree().get_nodes_in_group("buildings")
	towers = get_tree().get_nodes_in_group("towers")
	stadiums = get_tree().get_nodes_in_group("stadiums")
	districts = get_tree().get_nodes_in_group("districts")

	if only_once_structures == true:
		only_once_structures = false
		structures.append_array(buildings)
		structures.append_array(towers)
		structures.append_array(stadiums)
		structures.append_array(districts)

	print(structures.size())
		
	for i in structures.size():
		var structure_pos = local_to_map(structures[i].position)
		astar_grid.set_point_solid(structure_pos, true)	
	
	for i in get_node("../BattleManager").available_units.size():
		var unit_pos = local_to_map(get_node("../BattleManager").available_units[i].position)
		unitsCoord[i] = unit_pos
		get_node("../TileMap").astar_grid.set_point_solid(unit_pos, true)
		
	for i in get_node("../BattleManager").team_1.size():
		var unit_pos = local_to_map(get_node("../BattleManager").team_1[i].position)
		unitsCoord_1[i] = unit_pos
		get_node("../TileMap").astar_grid.set_point_solid(unit_pos, true)
		
	for i in get_node("../BattleManager").team_2.size():
		var unit_pos = local_to_map(get_node("../BattleManager").team_2[i].position)
		unitsCoord_2[i] = unit_pos	
		get_node("../TileMap").astar_grid.set_point_solid(unit_pos, true)				

	#Remove tiles that are off map
	for h in 16:
		for i in 16:
			set_cell(1, Vector2i(-16+h, i), -1, Vector2i(0, 0), 0)
	for h in 16:
		for i in 16:
			set_cell(1, Vector2i(16+h, i), -1, Vector2i(0, 0), 0)
	for h in 16:
		for i in 16:
			set_cell(1, Vector2i(h, -16+i), -1, Vector2i(0, 0), 0)
	for h in 16:
		for i in 16:
			set_cell(1, Vector2i(h, 16+i), -1, Vector2i(0, 0), 0)
		
		
	if moves_counter == 2:
		get_node("../TurnManager").advance_turn()
		moves_counter = 0
	
																				
func _input(event):						
	# Click and drag to move unit	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and hovertile.offset.y == 0 and moving == false:	
									
			var mouse_pos = get_global_mouse_position()
			var tile_pos = local_to_map(mouse_pos)	
			var tile_data = get_cell_tile_data(0, tile_pos)
			
			clicked_pos = tile_pos
						
			# Normal Attacks
			for h in get_node("../BattleManager").team_1.size():
				var surrounding_cells = get_node("../TileMap").get_surrounding_cells(get_node("../TileMap").unitsCoord_1[h])

				for i in 4:
					for j in get_node("../BattleManager").team_2.size():
						if surrounding_cells[i] == unitsCoord_2[j] and surrounding_cells[i] == tile_pos and get_cell_source_id(1, tile_pos) == 48:													
							var attack_center_pos = map_to_local(surrounding_cells[i]) + Vector2(0,0) / 2	
							if get_node("../BattleManager").team_1[right_clicked_unit].scale.x == 1 and get_node("../BattleManager").team_1[right_clicked_unit].position.x > attack_center_pos.x:
								get_node("../BattleManager").team_1[right_clicked_unit].scale.x = 1
								#print("1")
							elif get_node("../BattleManager").team_1[right_clicked_unit].scale.x == -1 and get_node("../BattleManager").team_1[right_clicked_unit].position.x < attack_center_pos.x:
								get_node("../BattleManager").team_1[right_clicked_unit].scale.x = -1
								#print("2")	
							if get_node("../BattleManager").team_1[right_clicked_unit].scale.x == -1 and get_node("../BattleManager").team_1[right_clicked_unit].position.x > attack_center_pos.x:
								get_node("../BattleManager").team_1[right_clicked_unit].scale.x = 1
								#print("3")
							elif get_node("../BattleManager").team_1[right_clicked_unit].scale.x == 1 and get_node("../BattleManager").team_1[right_clicked_unit].position.x < attack_center_pos.x:
								get_node("../BattleManager").team_1[right_clicked_unit].scale.x = -1
								#print("4")																																				

							get_node("../BattleManager").team_1[right_clicked_unit].get_child(0).play("attack")	
							
							get_child(1).stream = map_sfx[4]
							get_child(1).play()	
							
							await get_tree().create_timer(0.5).timeout
							get_node("../BattleManager").team_1[right_clicked_unit].get_child(0).play("default")
							
							get_node("../Camera2D").shake(0.5, 30, 3)
							
							var sfx
							
							if get_node("../BattleManager").team_1[right_clicked_unit].unit_name == "Panther":
								sfx = 5
							else:
								sfx = 3
								
							get_child(1).stream = map_sfx[sfx]
							get_child(1).play()	
							
							var _bumpedvector = surrounding_cells[i]
							if i == 0:
								var tile_center_pos = map_to_local(Vector2i(_bumpedvector.x+1, _bumpedvector.y)) + Vector2(0,0) / 2
								for k in get_node("../BattleManager").team_2.size():
									if surrounding_cells[i] == get_node("../TileMap").unitsCoord_2[k] and get_cell_source_id(1, tile_pos) == 48:
										get_node("../BattleManager").team_2[j].position = tile_center_pos
										unitsCoord_2[j] = tile_pos
										var unit_pos = local_to_map(get_node("../BattleManager").team_2[j].position)
										unitsCoord_2[j] = Vector2i(_bumpedvector.x+1, _bumpedvector.y)
										get_node("../BattleManager").team_2[j].position = tile_center_pos											
										get_node("../BattleManager").team_2[j].z_index = unit_pos.x + unit_pos.y
										var tween: Tween = create_tween()
										tween.tween_property(get_node("../BattleManager").team_2[j], "modulate:v", 1, 0.50).from(5)	
										await get_tree().create_timer(1).timeout
										get_node("../BattleManager").team_2[k].unit_min -= get_node("../BattleManager").team_1[h].unit_level
										get_node("../BattleManager").team_1[h].xp += 1
										get_node("../BattleManager").team_2[k].progressbar.set_value(get_node("../BattleManager").team_2[k].unit_min)										
										get_node("../TurnManager").advance_turn()
							if i == 1:
								var tile_center_pos = map_to_local(Vector2i(_bumpedvector.x, _bumpedvector.y+1)) + Vector2(0,0) / 2
								for k in get_node("../BattleManager").team_2.size():
									if surrounding_cells[i] == get_node("../TileMap").unitsCoord_2[k] and get_cell_source_id(1, tile_pos) == 48:
										get_node("../BattleManager").team_2[j].position = tile_center_pos								
										unitsCoord_2[j] = tile_pos
										var unit_pos = local_to_map(get_node("../BattleManager").team_2[j].position)
										unitsCoord_2[j] = Vector2i(_bumpedvector.x, _bumpedvector.y+1)
										get_node("../BattleManager").team_2[j].position = tile_center_pos											
										get_node("../BattleManager").team_2[j].z_index = unit_pos.x + unit_pos.y
										var tween: Tween = create_tween()
										tween.tween_property(get_node("../BattleManager").team_2[j], "modulate:v", 1, 0.50).from(5)
										await get_tree().create_timer(1).timeout
										get_node("../BattleManager").team_2[k].unit_min -= get_node("../BattleManager").team_1[h].unit_level
										get_node("../BattleManager").team_1[h].xp += 1
										get_node("../BattleManager").team_2[k].progressbar.set_value(get_node("../BattleManager").team_2[k].unit_min)								
										get_node("../TurnManager").advance_turn()
							if i == 2:
								var tile_center_pos = map_to_local(Vector2i(_bumpedvector.x-1, _bumpedvector.y)) + Vector2(0,0) / 2
								for k in get_node("../BattleManager").team_2.size():
									if surrounding_cells[i] == get_node("../TileMap").unitsCoord_2[k] and get_cell_source_id(1, tile_pos) == 48:
										get_node("../BattleManager").team_2[j].position = tile_center_pos								
										unitsCoord_2[j] = tile_pos
										var unit_pos = local_to_map(get_node("../BattleManager").team_2[j].position)
										unitsCoord_2[j] = Vector2i(_bumpedvector.x-1, _bumpedvector.y)
										get_node("../BattleManager").team_2[j].position = tile_center_pos											
										get_node("../BattleManager").team_2[j].z_index = unit_pos.x + unit_pos.y
										var tween: Tween = create_tween()
										tween.tween_property(get_node("../BattleManager").team_2[j].get_child(0), "modulate:v", 1, 0.50).from(5)	
										await get_tree().create_timer(1).timeout
										get_node("../BattleManager").team_2[k].unit_min -= get_node("../BattleManager").team_1[h].unit_level
										get_node("../BattleManager").team_1[h].xp += 1
										get_node("../BattleManager").team_2[k].progressbar.set_value(get_node("../BattleManager").team_2[k].unit_min)					
										get_node("../TurnManager").advance_turn()										
							if i == 3:
								var tile_center_pos = map_to_local(Vector2i(_bumpedvector.x, _bumpedvector.y-1)) + Vector2(0,0) / 2
								for k in get_node("../BattleManager").team_2.size():
									if surrounding_cells[i] == get_node("../TileMap").unitsCoord_2[k] and get_cell_source_id(1, tile_pos) == 48:
										get_node("../BattleManager").team_2[j].position = tile_center_pos						
										unitsCoord_2[j] = tile_pos
										var unit_pos = local_to_map(get_node("../BattleManager").team_2[j].position)
										unitsCoord_2[j] = Vector2i(_bumpedvector.x, _bumpedvector.y-1)
										get_node("../BattleManager").team_2[j].position = tile_center_pos											
										get_node("../BattleManager").team_2[j].z_index = unit_pos.x + unit_pos.y	
										var tween: Tween = create_tween()
										tween.tween_property(get_node("../BattleManager").team_2[j], "modulate:v", 1, 0.50).from(5)	
										await get_tree().create_timer(1).timeout
										get_node("../BattleManager").team_2[k].unit_min -= get_node("../BattleManager").team_1[h].unit_level
										get_node("../BattleManager").team_1[h].xp += 1
										get_node("../BattleManager").team_2[k].progressbar.set_value(get_node("../BattleManager").team_2[k].unit_min)			
										get_node("../TurnManager").advance_turn()
							return	
																							
			# Ranged Attack
			if only_once:
				for h in get_node("../BattleManager").team_2.size():					
					var clicked_center_pos = map_to_local(clicked_pos) + Vector2(0,0) / 2
						
					if clicked_center_pos == get_node("../BattleManager").team_2[h].position and get_cell_source_id(1, tile_pos) == 48 and get_node("../BattleManager").team_1[right_clicked_unit].unit_type == "Ranged":
						only_once = false
						
						var attack_center_pos = map_to_local(clicked_pos) + Vector2(0,0) / 2	
						
						if get_node("../BattleManager").team_1[right_clicked_unit].scale.x == 1 and get_node("../BattleManager").team_1[right_clicked_unit].position.x > attack_center_pos.x:
							get_node("../BattleManager").team_1[right_clicked_unit].scale.x = 1
						
						elif get_node("../BattleManager").team_1[right_clicked_unit].scale.x == -1 and get_node("../BattleManager").team_1[right_clicked_unit].position.x < attack_center_pos.x:
							get_node("../BattleManager").team_1[right_clicked_unit].scale.x = -1	
						
						if get_node("../BattleManager").team_1[right_clicked_unit].scale.x == -1 and get_node("../BattleManager").team_1[right_clicked_unit].position.x > attack_center_pos.x:
							get_node("../BattleManager").team_1[right_clicked_unit].scale.x = 1
						
						elif get_node("../BattleManager").team_1[right_clicked_unit].scale.x == 1 and get_node("../BattleManager").team_1[right_clicked_unit].position.x < attack_center_pos.x:
							get_node("../BattleManager").team_1[right_clicked_unit].scale.x = -1																																				
							
						
						get_node("../BattleManager").team_1[right_clicked_unit].get_child(0).play("attack")	
						
						get_child(1).stream = map_sfx[4]
						get_child(1).play()	
						
						await get_tree().create_timer(0.5).timeout
						get_node("../BattleManager").team_1[right_clicked_unit].get_child(0).play("default")		
						
						var _bumpedvector = clicked_pos
						var right_clicked_pos = local_to_map(get_node("../BattleManager").team_1[right_clicked_unit].position)
						
						get_node("../Camera2D").shake(0.5, 30, 3)
						
						get_child(1).stream = map_sfx[3]
						get_child(1).play()	
						
						if right_clicked_pos.y < clicked_pos.y and get_node("../BattleManager").team_1[right_clicked_unit].position.x > attack_center_pos.x:
							var tile_center_pos = map_to_local(Vector2i(_bumpedvector.x, _bumpedvector.y+1)) + Vector2(0,0) / 2
							get_node("../TileMap").get_node("../BattleManager").team_2[h].position = clicked_pos
							unitsCoord_2[h] = tile_pos										
							unitsCoord_2[h] = Vector2i(_bumpedvector.x, _bumpedvector.y+1)
							get_node("../BattleManager").team_2[h].position = tile_center_pos	
							var unit_pos = local_to_map(get_node("../BattleManager").team_2[h].position)										
							get_node("../BattleManager").team_2[h].z_index = unit_pos.x + unit_pos.y	
							var tween: Tween = create_tween()
							tween.tween_property(get_node("../BattleManager").team_2[h], "modulate:v", 1, 0.50).from(5)
							await get_tree().create_timer(1).timeout
							get_node("../BattleManager").team_2[h].unit_min -= get_node("../BattleManager").team_1[right_clicked_unit].unit_level
							get_node("../BattleManager").team_1[right_clicked_unit].xp += 1
							get_node("../BattleManager").team_2[h].progressbar.set_value(get_node("../BattleManager").team_2[h].unit_min)
							#print("A")
							
						if right_clicked_pos.y > clicked_pos.y and get_node("../BattleManager").team_1[right_clicked_unit].position.x < attack_center_pos.x:
							var tile_center_pos = map_to_local(Vector2i(_bumpedvector.x, _bumpedvector.y-1)) + Vector2(0,0) / 2
							get_node("../TileMap").get_node("../BattleManager").team_2[h].position = clicked_pos
							unitsCoord_2[h] = tile_pos										
							unitsCoord_2[h] = Vector2i(_bumpedvector.x, _bumpedvector.y-1)
							get_node("../BattleManager").team_2[h].position = tile_center_pos	
							var unit_pos = local_to_map(get_node("../BattleManager").team_2[h].position)										
							get_node("../BattleManager").team_2[h].z_index = unit_pos.x + unit_pos.y
							var tween: Tween = create_tween()
							tween.tween_property(get_node("../BattleManager").team_2[h], "modulate:v", 1, 0.50).from(5)										
							await get_tree().create_timer(1).timeout
							get_node("../BattleManager").team_2[h].unit_min -= get_node("../BattleManager").team_1[right_clicked_unit].unit_level
							get_node("../BattleManager").team_1[right_clicked_unit].xp += 1
							get_node("../BattleManager").team_2[h].progressbar.set_value(get_node("../BattleManager").team_2[h].unit_min)
							#print("B")
							
						if right_clicked_pos.x > clicked_pos.x and get_node("../BattleManager").team_1[right_clicked_unit].position.x > attack_center_pos.x:
							var tile_center_pos = map_to_local(Vector2i(_bumpedvector.x-1, _bumpedvector.y)) + Vector2(0,0) / 2										
							get_node("../TileMap").get_node("../BattleManager").team_2[h].position = clicked_pos
							unitsCoord_2[h] = tile_pos										
							unitsCoord_2[h] = Vector2i(_bumpedvector.x-1, _bumpedvector.y)
							get_node("../BattleManager").team_2[h].position = tile_center_pos	
							var unit_pos = local_to_map(get_node("../BattleManager").team_2[h].position)										
							get_node("../BattleManager").team_2[h].z_index = unit_pos.x + unit_pos.y
							var tween: Tween = create_tween()
							tween.tween_property(get_node("../BattleManager").team_2[h], "modulate:v", 1, 0.50).from(5)	
							await get_tree().create_timer(1).timeout
							get_node("../BattleManager").team_2[h].unit_min -= get_node("../BattleManager").team_1[right_clicked_unit].unit_level
							get_node("../BattleManager").team_1[right_clicked_unit].xp += 1
							get_node("../BattleManager").team_2[h].progressbar.set_value(get_node("../BattleManager").team_2[h].unit_min)
							#print("C")
							
						if right_clicked_pos.x < clicked_pos.x and get_node("../BattleManager").team_1[right_clicked_unit].position.x < attack_center_pos.x:
							var tile_center_pos = map_to_local(Vector2i(_bumpedvector.x+1, _bumpedvector.y)) + Vector2(0,0) / 2
							get_node("../TileMap").get_node("../BattleManager").team_2[h].position = clicked_pos
							unitsCoord_2[h] = tile_pos										
							unitsCoord_2[h] = Vector2i(_bumpedvector.x+1, _bumpedvector.y)
							get_node("../BattleManager").team_2[h].position = tile_center_pos	
							var unit_pos = local_to_map(get_node("../BattleManager").team_2[h].position)										
							get_node("../BattleManager").team_2[h].z_index = unit_pos.x + unit_pos.y		
							var tween: Tween = create_tween()
							tween.tween_property(get_node("../BattleManager").team_2[h], "modulate:v", 1, 0.50).from(5)
							await get_tree().create_timer(1).timeout
							get_node("../BattleManager").team_2[h].unit_min -= get_node("../BattleManager").team_1[right_clicked_unit].unit_level
							get_node("../BattleManager").team_1[right_clicked_unit].xp += 1
							get_node("../BattleManager").team_2[h].progressbar.set_value(get_node("../BattleManager").team_2[h].unit_min)
							#print("D")
							
						get_node("../TurnManager").advance_turn()
						only_once = true
							
			# Special Attack
			for h in get_node("../BattleManager").team_1.size():
				var surrounding_cells = get_node("../TileMap").get_surrounding_cells(get_node("../TileMap").unitsCoord_1[h])

				for i in 4:
					for j in get_node("../BattleManager").team_2.size():
						if surrounding_cells[i] == unitsCoord_2[j] and surrounding_cells[i] == tile_pos and get_cell_source_id(1, tile_pos) == 24:
							var attack_center_pos = map_to_local(surrounding_cells[i]) + Vector2(0,0) / 2	
							
							if get_node("../BattleManager").team_1[right_clicked_unit].scale.x == 1 and get_node("../BattleManager").team_1[right_clicked_unit].position.x > attack_center_pos.x:
								get_node("../BattleManager").team_1[right_clicked_unit].scale.x = 1
								#print("1")
							elif get_node("../BattleManager").team_1[right_clicked_unit].scale.x == -1 and get_node("../BattleManager").team_1[right_clicked_unit].position.x < attack_center_pos.x:
								get_node("../BattleManager").team_1[right_clicked_unit].scale.x = -1
								#print("2")	
							if get_node("../BattleManager").team_1[right_clicked_unit].scale.x == -1 and get_node("../BattleManager").team_1[right_clicked_unit].position.x > attack_center_pos.x:
								get_node("../BattleManager").team_1[right_clicked_unit].scale.x = 1
								#print("3")
							elif get_node("../BattleManager").team_1[right_clicked_unit].scale.x == 1 and get_node("../BattleManager").team_1[right_clicked_unit].position.x < attack_center_pos.x:
								get_node("../BattleManager").team_1[right_clicked_unit].scale.x = -1
								#print("4")																																				

							get_node("../BattleManager").team_1[right_clicked_unit].get_child(0).play("attack")	
							
							get_child(1).stream = map_sfx[4]
							get_child(1).play()	
							
							await get_tree().create_timer(1).timeout
							get_node("../BattleManager").team_1[right_clicked_unit].get_child(0).play("default")
							
							get_node("../Camera2D").shake(0.5, 30, 3)
							
							var sfx
							
							if get_node("../BattleManager").team_1[right_clicked_unit].unit_name == "Panther":
								sfx = 5
							else:
								sfx = 3
								
							get_child(1).stream = map_sfx[sfx]
							get_child(1).play()	

							#hovertile_type = 48	
													
							var _bumpedvector = surrounding_cells[i]
							if i == 0:
								var tile_center_pos = map_to_local(Vector2i(_bumpedvector.x+1, _bumpedvector.y)) + Vector2(0,0) / 2
								for k in get_node("../BattleManager").team_2.size():
									if surrounding_cells[i] == get_node("../TileMap").unitsCoord_2[k] and get_cell_source_id(1, tile_pos) == 24:
										get_node("../BattleManager").team_2[j].position = tile_center_pos
										unitsCoord_2[j] = tile_pos
										var unit_pos = local_to_map(get_node("../BattleManager").team_2[j].position)
										unitsCoord_2[j] = Vector2i(_bumpedvector.x+1, _bumpedvector.y)
										get_node("../BattleManager").team_2[j].position = tile_center_pos											
										get_node("../BattleManager").team_2[j].z_index = unit_pos.x + unit_pos.y
										var tween: Tween = create_tween()
										tween.tween_property(get_node("../BattleManager").team_2[j], "modulate:v", 1, 0.50).from(5)	
						
										get_node("../BattleManager").team_2[k].unit_min -= get_node("../BattleManager").team_1[h].unit_level
										get_node("../BattleManager").team_1[h].xp += 1
										get_node("../BattleManager").team_2[k].progressbar.set_value(get_node("../BattleManager").team_2[k].unit_min)
										await get_tree().create_timer(1).timeout
										get_node("../BattleManager").team_2[k].unit_min -= get_node("../BattleManager").team_1[h].unit_level
										get_node("../BattleManager").team_1[h].xp += 1
										get_node("../BattleManager").team_2[k].progressbar.set_value(get_node("../BattleManager").team_2[k].unit_min)										
										
										var unit_center_pos = get_node("../TileMap").local_to_map(get_node("../BattleManager").team_2[k].position)		
										var unit_cell_center_pos = get_node("../TileMap").map_to_local(unit_center_pos) + Vector2(0,0) / 2		
										var explosion = preload("res://prefab/vfx/explosion_area_2d.tscn")
										var explosion_instance = explosion.instantiate()
										var explosion_pos = get_node("../TileMap").map_to_local(unit_center_pos) + Vector2(0,0) / 2
										explosion_instance.set_name("explosion")
										get_node("../TileMap").add_child(explosion_instance)
										get_parent().add_child(explosion_instance)
										explosion_instance.position = unit_cell_center_pos
										explosion_instance.z_index = explosion_pos.x + explosion_pos.y	
																													
										get_node("../TurnManager").advance_turn()
							
							if i == 1:
								var tile_center_pos = map_to_local(Vector2i(_bumpedvector.x, _bumpedvector.y+1)) + Vector2(0,0) / 2
								for k in get_node("../BattleManager").team_2.size():
									if surrounding_cells[i] == get_node("../TileMap").unitsCoord_2[k] and get_cell_source_id(1, tile_pos) == 24:
										get_node("../BattleManager").team_2[j].position = tile_center_pos								
										unitsCoord_2[j] = tile_pos
										var unit_pos = local_to_map(get_node("../BattleManager").team_2[j].position)
										unitsCoord_2[j] = Vector2i(_bumpedvector.x, _bumpedvector.y+1)
										get_node("../BattleManager").team_2[j].position = tile_center_pos											
										get_node("../BattleManager").team_2[j].z_index = unit_pos.x + unit_pos.y
										var tween: Tween = create_tween()
										tween.tween_property(get_node("../BattleManager").team_2[j], "modulate:v", 1, 0.50).from(5)
										
										get_node("../BattleManager").team_2[k].unit_min -= get_node("../BattleManager").team_1[h].unit_level
										get_node("../BattleManager").team_1[h].xp += 1
										get_node("../BattleManager").team_2[k].progressbar.set_value(get_node("../BattleManager").team_2[k].unit_min)										
										await get_tree().create_timer(1).timeout
										get_node("../BattleManager").team_2[k].unit_min -= get_node("../BattleManager").team_1[h].unit_level
										get_node("../BattleManager").team_1[h].xp += 1
										get_node("../BattleManager").team_2[k].progressbar.set_value(get_node("../BattleManager").team_2[k].unit_min)								

										var unit_center_pos = get_node("../TileMap").local_to_map(get_node("../BattleManager").team_2[k].position)		
										var unit_cell_center_pos = get_node("../TileMap").map_to_local(unit_center_pos) + Vector2(0,0) / 2		
										var explosion = preload("res://prefab/vfx/explosion_area_2d.tscn")
										var explosion_instance = explosion.instantiate()
										var explosion_pos = get_node("../TileMap").map_to_local(unit_center_pos) + Vector2(0,0) / 2
										explosion_instance.set_name("explosion")
										get_node("../TileMap").add_child(explosion_instance)
										get_parent().add_child(explosion_instance)
										explosion_instance.position = unit_cell_center_pos
										explosion_instance.z_index = explosion_pos.x + explosion_pos.y											
										
										get_node("../TurnManager").advance_turn()
							if i == 2:
								var tile_center_pos = map_to_local(Vector2i(_bumpedvector.x-1, _bumpedvector.y)) + Vector2(0,0) / 2
								for k in get_node("../BattleManager").team_2.size():
									if surrounding_cells[i] == get_node("../TileMap").unitsCoord_2[k] and get_cell_source_id(1, tile_pos) == 24:
										get_node("../BattleManager").team_2[j].position = tile_center_pos								
										unitsCoord_2[j] = tile_pos
										var unit_pos = local_to_map(get_node("../BattleManager").team_2[j].position)
										unitsCoord_2[j] = Vector2i(_bumpedvector.x-1, _bumpedvector.y)
										get_node("../BattleManager").team_2[j].position = tile_center_pos											
										get_node("../BattleManager").team_2[j].z_index = unit_pos.x + unit_pos.y
										var tween: Tween = create_tween()
										tween.tween_property(get_node("../BattleManager").team_2[j].get_child(0), "modulate:v", 1, 0.50).from(5)
											
										get_node("../BattleManager").team_2[k].unit_min -= get_node("../BattleManager").team_1[h].unit_level
										get_node("../BattleManager").team_1[h].xp += 1
										get_node("../BattleManager").team_2[k].progressbar.set_value(get_node("../BattleManager").team_2[k].unit_min)										
										await get_tree().create_timer(1).timeout
										get_node("../BattleManager").team_2[k].unit_min -= get_node("../BattleManager").team_1[h].unit_level
										get_node("../BattleManager").team_1[h].xp += 1
										get_node("../BattleManager").team_2[k].progressbar.set_value(get_node("../BattleManager").team_2[k].unit_min)					

										var unit_center_pos = get_node("../TileMap").local_to_map(get_node("../BattleManager").team_2[k].position)		
										var unit_cell_center_pos = get_node("../TileMap").map_to_local(unit_center_pos) + Vector2(0,0) / 2		
										var explosion = preload("res://prefab/vfx/explosion_area_2d.tscn")
										var explosion_instance = explosion.instantiate()
										var explosion_pos = get_node("../TileMap").map_to_local(unit_center_pos) + Vector2(0,0) / 2
										explosion_instance.set_name("explosion")
										get_node("../TileMap").add_child(explosion_instance)
										get_parent().add_child(explosion_instance)
										explosion_instance.position = unit_cell_center_pos
										explosion_instance.z_index = explosion_pos.x + explosion_pos.y	

										get_node("../TurnManager").advance_turn()
										
							if i == 3:
								var tile_center_pos = map_to_local(Vector2i(_bumpedvector.x, _bumpedvector.y-1)) + Vector2(0,0) / 2
								for k in get_node("../BattleManager").team_2.size():
									if surrounding_cells[i] == get_node("../TileMap").unitsCoord_2[k] and get_cell_source_id(1, tile_pos) == 24:
										get_node("../BattleManager").team_2[j].position = tile_center_pos						
										unitsCoord_2[j] = tile_pos
										var unit_pos = local_to_map(get_node("../BattleManager").team_2[j].position)
										unitsCoord_2[j] = Vector2i(_bumpedvector.x, _bumpedvector.y-1)
										get_node("../BattleManager").team_2[j].position = tile_center_pos											
										get_node("../BattleManager").team_2[j].z_index = unit_pos.x + unit_pos.y	
										var tween: Tween = create_tween()
										tween.tween_property(get_node("../BattleManager").team_2[j], "modulate:v", 1, 0.50).from(5)	
										
										get_node("../BattleManager").team_2[k].unit_min -= get_node("../BattleManager").team_1[h].unit_level
										get_node("../BattleManager").team_1[h].xp += 1
										get_node("../BattleManager").team_2[k].progressbar.set_value(get_node("../BattleManager").team_2[k].unit_min)										
										await get_tree().create_timer(1).timeout
										get_node("../BattleManager").team_2[k].unit_min -= get_node("../BattleManager").team_1[h].unit_level
										get_node("../BattleManager").team_1[h].xp += 1
										get_node("../BattleManager").team_2[k].progressbar.set_value(get_node("../BattleManager").team_2[k].unit_min)			

										var unit_center_pos = get_node("../TileMap").local_to_map(get_node("../BattleManager").team_2[k].position)		
										var unit_cell_center_pos = get_node("../TileMap").map_to_local(unit_center_pos) + Vector2(0,0) / 2		
										var explosion = preload("res://prefab/vfx/explosion_area_2d.tscn")
										var explosion_instance = explosion.instantiate()
										var explosion_pos = get_node("../TileMap").map_to_local(unit_center_pos) + Vector2(0,0) / 2
										explosion_instance.set_name("explosion")
										get_node("../TileMap").add_child(explosion_instance)
										get_parent().add_child(explosion_instance)
										explosion_instance.position = unit_cell_center_pos
										explosion_instance.z_index = explosion_pos.x + explosion_pos.y	

										get_node("../TurnManager").advance_turn()
							return	
							
			# Special Ranged Attack
			if only_once:
				for h in get_node("../BattleManager").team_2.size():					
					var clicked_center_pos = map_to_local(clicked_pos) + Vector2(0,0) / 2
						
					if clicked_center_pos == get_node("../BattleManager").team_2[h].position and get_cell_source_id(1, tile_pos) == 24 and get_node("../BattleManager").team_1[right_clicked_unit].unit_type == "Ranged":
						only_once = false
						
						var attack_center_pos = map_to_local(clicked_pos) + Vector2(0,0) / 2	
						
						if get_node("../BattleManager").team_1[right_clicked_unit].scale.x == 1 and get_node("../BattleManager").team_1[right_clicked_unit].position.x > attack_center_pos.x:
							get_node("../BattleManager").team_1[right_clicked_unit].scale.x = 1
						
						elif get_node("../BattleManager").team_1[right_clicked_unit].scale.x == -1 and get_node("../BattleManager").team_1[right_clicked_unit].position.x < attack_center_pos.x:
							get_node("../BattleManager").team_1[right_clicked_unit].scale.x = -1	
						
						if get_node("../BattleManager").team_1[right_clicked_unit].scale.x == -1 and get_node("../BattleManager").team_1[right_clicked_unit].position.x > attack_center_pos.x:
							get_node("../BattleManager").team_1[right_clicked_unit].scale.x = 1
						
						elif get_node("../BattleManager").team_1[right_clicked_unit].scale.x == 1 and get_node("../BattleManager").team_1[right_clicked_unit].position.x < attack_center_pos.x:
							get_node("../BattleManager").team_1[right_clicked_unit].scale.x = -1																																				
							
						
						get_node("../BattleManager").team_1[right_clicked_unit].get_child(0).play("attack")	
						
						get_child(1).stream = map_sfx[4]
						get_child(1).play()	
						
						await get_tree().create_timer(1).timeout
						get_node("../BattleManager").team_1[right_clicked_unit].get_child(0).play("default")		
						
						var _bumpedvector = clicked_pos
						var right_clicked_pos = local_to_map(get_node("../BattleManager").team_1[right_clicked_unit].position)
						
						get_node("../Camera2D").shake(0.5, 30, 3)
						
						get_child(1).stream = map_sfx[3]
						get_child(1).play()	
						
						#hovertile_type = 48
						
						if right_clicked_pos.y < clicked_pos.y and get_node("../BattleManager").team_1[right_clicked_unit].position.x > attack_center_pos.x:
							var tile_center_pos = map_to_local(Vector2i(_bumpedvector.x, _bumpedvector.y+1)) + Vector2(0,0) / 2
							get_node("../TileMap").get_node("../BattleManager").team_2[h].position = clicked_pos
							unitsCoord_2[h] = tile_pos										
							unitsCoord_2[h] = Vector2i(_bumpedvector.x, _bumpedvector.y+1)
							get_node("../BattleManager").team_2[h].position = tile_center_pos	
							var unit_pos = local_to_map(get_node("../BattleManager").team_2[h].position)										
							get_node("../BattleManager").team_2[h].z_index = unit_pos.x + unit_pos.y	
							var tween: Tween = create_tween()
							tween.tween_property(get_node("../BattleManager").team_2[h], "modulate:v", 1, 0.50).from(5)

							get_node("../BattleManager").team_2[h].unit_min -= get_node("../BattleManager").team_1[right_clicked_unit].unit_level
							get_node("../BattleManager").team_1[right_clicked_unit].xp += 1
							get_node("../BattleManager").team_2[h].progressbar.set_value(get_node("../BattleManager").team_2[h].unit_min)
							await get_tree().create_timer(1).timeout
							get_node("../BattleManager").team_2[h].unit_min -= get_node("../BattleManager").team_1[right_clicked_unit].unit_level
							get_node("../BattleManager").team_1[right_clicked_unit].xp += 1
							get_node("../BattleManager").team_2[h].progressbar.set_value(get_node("../BattleManager").team_2[h].unit_min)
							#print("A")
							
							var unit_center_pos = get_node("../TileMap").local_to_map(get_node("../BattleManager").team_2[h].position)		
							var unit_cell_center_pos = get_node("../TileMap").map_to_local(unit_center_pos) + Vector2(0,0) / 2		
							var explosion = preload("res://prefab/vfx/explosion_area_2d.tscn")
							var explosion_instance = explosion.instantiate()
							var explosion_pos = get_node("../TileMap").map_to_local(unit_center_pos) + Vector2(0,0) / 2
							explosion_instance.set_name("explosion")
							get_node("../TileMap").add_child(explosion_instance)
							get_parent().add_child(explosion_instance)
							explosion_instance.position = unit_cell_center_pos
							explosion_instance.z_index = explosion_pos.x + explosion_pos.y	

							
						if right_clicked_pos.y > clicked_pos.y and get_node("../BattleManager").team_1[right_clicked_unit].position.x < attack_center_pos.x:
							var tile_center_pos = map_to_local(Vector2i(_bumpedvector.x, _bumpedvector.y-1)) + Vector2(0,0) / 2
							get_node("../TileMap").get_node("../BattleManager").team_2[h].position = clicked_pos
							unitsCoord_2[h] = tile_pos										
							unitsCoord_2[h] = Vector2i(_bumpedvector.x, _bumpedvector.y-1)
							get_node("../BattleManager").team_2[h].position = tile_center_pos	
							var unit_pos = local_to_map(get_node("../BattleManager").team_2[h].position)										
							get_node("../BattleManager").team_2[h].z_index = unit_pos.x + unit_pos.y
							var tween: Tween = create_tween()
							tween.tween_property(get_node("../BattleManager").team_2[h], "modulate:v", 1, 0.50).from(5)										
							
							get_node("../BattleManager").team_2[h].unit_min -= get_node("../BattleManager").team_1[right_clicked_unit].unit_level
							get_node("../BattleManager").team_1[right_clicked_unit].xp += 1
							get_node("../BattleManager").team_2[h].progressbar.set_value(get_node("../BattleManager").team_2[h].unit_min)							
							await get_tree().create_timer(1).timeout
							get_node("../BattleManager").team_2[h].unit_min -= get_node("../BattleManager").team_1[right_clicked_unit].unit_level
							get_node("../BattleManager").team_1[right_clicked_unit].xp += 1
							get_node("../BattleManager").team_2[h].progressbar.set_value(get_node("../BattleManager").team_2[h].unit_min)
							#print("B")

							var unit_center_pos = get_node("../TileMap").local_to_map(get_node("../BattleManager").team_2[h].position)		
							var unit_cell_center_pos = get_node("../TileMap").map_to_local(unit_center_pos) + Vector2(0,0) / 2		
							var explosion = preload("res://prefab/vfx/explosion_area_2d.tscn")
							var explosion_instance = explosion.instantiate()
							var explosion_pos = get_node("../TileMap").map_to_local(unit_center_pos) + Vector2(0,0) / 2
							explosion_instance.set_name("explosion")
							get_node("../TileMap").add_child(explosion_instance)
							get_parent().add_child(explosion_instance)
							explosion_instance.position = unit_cell_center_pos
							explosion_instance.z_index = explosion_pos.x + explosion_pos.y
							
						if right_clicked_pos.x > clicked_pos.x and get_node("../BattleManager").team_1[right_clicked_unit].position.x > attack_center_pos.x:
							var tile_center_pos = map_to_local(Vector2i(_bumpedvector.x-1, _bumpedvector.y)) + Vector2(0,0) / 2										
							get_node("../TileMap").get_node("../BattleManager").team_2[h].position = clicked_pos
							unitsCoord_2[h] = tile_pos										
							unitsCoord_2[h] = Vector2i(_bumpedvector.x-1, _bumpedvector.y)
							get_node("../BattleManager").team_2[h].position = tile_center_pos	
							var unit_pos = local_to_map(get_node("../BattleManager").team_2[h].position)										
							get_node("../BattleManager").team_2[h].z_index = unit_pos.x + unit_pos.y
							var tween: Tween = create_tween()
							tween.tween_property(get_node("../BattleManager").team_2[h], "modulate:v", 1, 0.50).from(5)	
							
							get_node("../BattleManager").team_2[h].unit_min -= get_node("../BattleManager").team_1[right_clicked_unit].unit_level
							get_node("../BattleManager").team_1[right_clicked_unit].xp += 1
							get_node("../BattleManager").team_2[h].progressbar.set_value(get_node("../BattleManager").team_2[h].unit_min)														
							await get_tree().create_timer(1).timeout
							get_node("../BattleManager").team_2[h].unit_min -= get_node("../BattleManager").team_1[right_clicked_unit].unit_level
							get_node("../BattleManager").team_1[right_clicked_unit].xp += 1
							get_node("../BattleManager").team_2[h].progressbar.set_value(get_node("../BattleManager").team_2[h].unit_min)
							#print("C")

							var unit_center_pos = get_node("../TileMap").local_to_map(get_node("../BattleManager").team_2[h].position)		
							var unit_cell_center_pos = get_node("../TileMap").map_to_local(unit_center_pos) + Vector2(0,0) / 2		
							var explosion = preload("res://prefab/vfx/explosion_area_2d.tscn")
							var explosion_instance = explosion.instantiate()
							var explosion_pos = get_node("../TileMap").map_to_local(unit_center_pos) + Vector2(0,0) / 2
							explosion_instance.set_name("explosion")
							get_node("../TileMap").add_child(explosion_instance)
							get_parent().add_child(explosion_instance)
							explosion_instance.position = unit_cell_center_pos
							explosion_instance.z_index = explosion_pos.x + explosion_pos.y
							
						if right_clicked_pos.x < clicked_pos.x and get_node("../BattleManager").team_1[right_clicked_unit].position.x < attack_center_pos.x:
							var tile_center_pos = map_to_local(Vector2i(_bumpedvector.x+1, _bumpedvector.y)) + Vector2(0,0) / 2
							get_node("../TileMap").get_node("../BattleManager").team_2[h].position = clicked_pos
							unitsCoord_2[h] = tile_pos										
							unitsCoord_2[h] = Vector2i(_bumpedvector.x+1, _bumpedvector.y)
							get_node("../BattleManager").team_2[h].position = tile_center_pos	
							var unit_pos = local_to_map(get_node("../BattleManager").team_2[h].position)										
							get_node("../BattleManager").team_2[h].z_index = unit_pos.x + unit_pos.y		
							var tween: Tween = create_tween()
							tween.tween_property(get_node("../BattleManager").team_2[h], "modulate:v", 1, 0.50).from(5)
							
							get_node("../BattleManager").team_2[h].unit_min -= get_node("../BattleManager").team_1[right_clicked_unit].unit_level
							get_node("../BattleManager").team_1[right_clicked_unit].xp += 1
							get_node("../BattleManager").team_2[h].progressbar.set_value(get_node("../BattleManager").team_2[h].unit_min)							
							await get_tree().create_timer(1).timeout
							get_node("../BattleManager").team_2[h].unit_min -= get_node("../BattleManager").team_1[right_clicked_unit].unit_level
							get_node("../BattleManager").team_1[right_clicked_unit].xp += 1
							get_node("../BattleManager").team_2[h].progressbar.set_value(get_node("../BattleManager").team_2[h].unit_min)
							#print("D")

							var unit_center_pos = get_node("../TileMap").local_to_map(get_node("../BattleManager").team_2[h].position)		
							var unit_cell_center_pos = get_node("../TileMap").map_to_local(unit_center_pos) + Vector2(0,0) / 2		
							var explosion = preload("res://prefab/vfx/explosion_area_2d.tscn")
							var explosion_instance = explosion.instantiate()
							var explosion_pos = get_node("../TileMap").map_to_local(unit_center_pos) + Vector2(0,0) / 2
							explosion_instance.set_name("explosion")
							get_node("../TileMap").add_child(explosion_instance)
							get_parent().add_child(explosion_instance)
							explosion_instance.position = unit_cell_center_pos
							explosion_instance.z_index = explosion_pos.x + explosion_pos.y
							
						get_node("../TurnManager").advance_turn()
						only_once = true
						
			#Remove hover tiles										
			for j in grid_height:
				for k in grid_width:
					set_cell(1, Vector2i(j,k), -1, Vector2i(0, 0), 0)
			
			#Place hover tiles		
			if tile_data is TileData:			
				for i in get_node("../BattleManager").team_1.size():
					if get_node("../TileMap").unitsCoord_1[get_node("../BattleManager").team_1[i].unit_num] == tile_pos:
						
						hovertile.set_offset(Vector2(0,-10))
						get_node("../BattleManager").team_1[i].get_child(0).set_offset(Vector2(0,-10))
						clicked_unit = get_node("../BattleManager").team_1[i].unit_num
						get_child(1).stream = map_sfx[0]
						get_child(1).play()
														
						for j in get_node("../BattleManager").team_1[i].unit_movement:
							var surrounding_cells = get_node("../TileMap").get_surrounding_cells(get_node("../TileMap").unitsCoord_1[i])
							
							if get_node("../BattleManager").team_1[i].unit_movement == 1:
								for k in surrounding_cells.size():
									set_cell(1, tile_pos, -1, Vector2i(0, 0), 0)
									set_cell(1, Vector2i(surrounding_cells[k].x, surrounding_cells[k].y), 18, Vector2i(0, 0), 0)
									if surrounding_cells[k].x <= -1 or surrounding_cells[k].y >= 16 or surrounding_cells[k].x >= 16 or surrounding_cells[k].y <= -1:
										set_cell(1, tile_pos, -1, Vector2i(0, 0), 0)
										set_cell(1, Vector2i(surrounding_cells[k].x, surrounding_cells[k].y), -1, Vector2i(0, 0), 0)
										
							if get_node("../BattleManager").team_1[i].unit_movement == 2:
								for k in surrounding_cells.size():
									set_cell(1, tile_pos, -1, Vector2i(0, 0), 0)
									set_cell(1, Vector2i(surrounding_cells[k].x, surrounding_cells[k].y), 18, Vector2i(0, 0), 0)										
									if surrounding_cells[k].x <= -1 or surrounding_cells[k].y >= 16 or surrounding_cells[k].x >= 16 or surrounding_cells[k].y <= -1:
										set_cell(1, tile_pos, -1, Vector2i(0, 0), 0)
										set_cell(1, Vector2i(surrounding_cells[k].x, surrounding_cells[k].y), -1, Vector2i(0, 0), 0)								
								for k in surrounding_cells.size():
									set_cell(1, Vector2i(surrounding_cells[k].x+1, surrounding_cells[k].y), 18, Vector2i(0, 0), 0)																																								
									set_cell(1, Vector2i(surrounding_cells[k].x-1, surrounding_cells[k].y), 18, Vector2i(0, 0), 0)															
									set_cell(1, Vector2i(surrounding_cells[k].x, surrounding_cells[k].y+1), 18, Vector2i(0, 0), 0)																																								
									set_cell(1, Vector2i(surrounding_cells[k].x, surrounding_cells[k].y-1), 18, Vector2i(0, 0), 0)									
									set_cell(1, tile_pos, -1, Vector2i(0, 0), 0)	
							
							if get_node("../BattleManager").team_1[i].unit_movement == 3:
								for k in surrounding_cells.size():
									set_cell(1, tile_pos, -1, Vector2i(0, 0), 0)
									set_cell(1, Vector2i(surrounding_cells[k].x, surrounding_cells[k].y), 18, Vector2i(0, 0), 0)									
									if surrounding_cells[k].x <= -1 or surrounding_cells[k].y >= 16 or surrounding_cells[k].x >= 16 or surrounding_cells[k].y <= -1:
										set_cell(1, tile_pos, -1, Vector2i(0, 0), 0)
										set_cell(1, Vector2i(surrounding_cells[k].x, surrounding_cells[k].y), -1, Vector2i(0, 0), 0)								
								for k in surrounding_cells.size():
									set_cell(1, tile_pos, -1, Vector2i(0, 0), 0)
									set_cell(1, Vector2i(surrounding_cells[k].x+1, surrounding_cells[k].y), 18, Vector2i(0, 0), 0)																																								
									set_cell(1, Vector2i(surrounding_cells[k].x-1, surrounding_cells[k].y), 18, Vector2i(0, 0), 0)															
									set_cell(1, Vector2i(surrounding_cells[k].x, surrounding_cells[k].y+1), 18, Vector2i(0, 0), 0)																																								
									set_cell(1, Vector2i(surrounding_cells[k].x, surrounding_cells[k].y-1), 18, Vector2i(0, 0), 0)								
								for k in surrounding_cells.size():
									set_cell(1, tile_pos, -1, Vector2i(0, 0), 0)
									set_cell(1, Vector2i(surrounding_cells[k].x+2, surrounding_cells[k].y), 18, Vector2i(0, 0), 0)																																								
									set_cell(1, Vector2i(surrounding_cells[k].x-2, surrounding_cells[k].y), 18, Vector2i(0, 0), 0)															
									set_cell(1, Vector2i(surrounding_cells[k].x, surrounding_cells[k].y+2), 18, Vector2i(0, 0), 0)																																								
									set_cell(1, Vector2i(surrounding_cells[k].x, surrounding_cells[k].y-2), 18, Vector2i(0, 0), 0)						
															
			#print("Holding")

					
		# Drop unit on mouse up																					
		elif hovertile.offset.y == -10:	
			var mouse_pos = get_global_mouse_position()
			var tile_pos = local_to_map(mouse_pos)
			
			if tile_pos == unitsCoord[clicked_unit]:
				hovertile.set_offset(Vector2(0,0))
				get_node("../BattleManager").team_1[clicked_unit].get_child(0).set_offset(Vector2(0,0))					
				return				
				
			hovertile.set_offset(Vector2(0,0))
			for i in get_node("../BattleManager").team_1.size():
				if get_node("../BattleManager").team_1[i].get_child(0).offset == (Vector2(0,-10)) and get_node("../BattleManager").team_1[i].unit_team == 1 and get_cell_source_id(1, tile_pos) == 18:					
					#Remove hover tiles										
					for j in grid_height:
						for k in grid_width:
							set_cell(1, Vector2i(j,k), -1, Vector2i(0, 0), 0)					
					
					get_node("../BattleManager").team_1[i].get_child(0).set_offset(Vector2(0,0))	
					dropped_pos = tile_pos
					var patharray = astar_grid.get_point_path(clicked_pos, dropped_pos)
					get_node("../BattleManager").team_1[i].get_child(0).play("move")
					hovertile.hide()
					moving = true
					
					# Find path and set hover cells
					for h in patharray.size():
						await get_tree().create_timer(0.01).timeout
						set_cell(1, patharray[h], 18, Vector2i(0, 0), 0)
					# Move unit		
					for h in patharray.size():
						var tile_center_pos = map_to_local(patharray[h]) + Vector2(0,0) / 2
						var tween = create_tween()
						tween.tween_property(get_node("../BattleManager").team_1[i], "position", tile_center_pos, 0.35)
						unitsCoord[i] = tile_pos
						var unit_pos = local_to_map(get_node("../BattleManager").team_1[i].position)
						get_node("../BattleManager").team_1[i].z_index = unit_pos.x + unit_pos.y
						get_child(1).stream = map_sfx[2]
						get_child(1).play()				
						await get_tree().create_timer(0.35).timeout
					
					# Remove hover cells
					for h in patharray.size():
						set_cell(1, patharray[h], -1, Vector2i(0, 0), 0)
					
					moving = false
					
					hovertile.show()
					# Set moving to false			
					var unit_pos = local_to_map(get_node("../BattleManager").team_1[i].position)
					get_node("../BattleManager").team_1[i].z_index = unit_pos.x + unit_pos.y													
					get_node("../BattleManager").team_1[i].get_child(0).play("default")
					
					#Remove hover tiles										
					for j in grid_height:
						for k in grid_width:
							set_cell(1, Vector2i(j,k), -1, Vector2i(0, 0), 0)				
					
					var just_moved = true
					if just_moved == true:
						moves_counter += 1
						just_moved = false
						
					await get_tree().create_timer(1).timeout
					
				get_node("../BattleManager").team_1[i].get_child(0).set_offset(Vector2(0,0))		

			

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and hovertile.offset.y == 0 and moving == false:
			#Remove hover tiles										
			for j in grid_height:
				for k in grid_width:
					set_cell(1, Vector2i(j,k), -1, Vector2i(0, 0), 0)
																			
			var mouse_pos = get_global_mouse_position()
			var tile_pos = local_to_map(mouse_pos)		

			var tile_data = get_cell_tile_data(0, tile_pos)

			if tile_data is TileData:				
				for i in get_node("../BattleManager").team_1.size():
					var unit_pos = local_to_map(get_node("../BattleManager").team_1[i].position)

					if unit_pos == tile_pos and get_node("../BattleManager").team_1[i].get_child(0).use_parent_material == false:
						right_clicked_unit = get_node("../BattleManager").team_1[i].unit_num
						unit_type = get_node("../BattleManager").team_1[i].unit_type
						get_node("../BattleManager").team_1[i].position = hovertile.position
						
						get_child(1).stream = map_sfx[1]
						get_child(1).play()							
						
						if unit_type == "Melee":
							set_cell(1, tile_pos, -1, Vector2i(0, 0), 0)	
							set_cell(1, Vector2i(tile_pos.x-1, tile_pos.y), hovertile_type, Vector2i(0, 0), 0)
							set_cell(1, Vector2i(tile_pos.x+1, tile_pos.y), hovertile_type, Vector2i(0, 0), 0)
							set_cell(1, Vector2i(tile_pos.x, tile_pos.y-1), hovertile_type, Vector2i(0, 0), 0)
							set_cell(1, Vector2i(tile_pos.x, tile_pos.y+1), hovertile_type, Vector2i(0, 0), 0)

						if unit_type == "Support":
							set_cell(1, tile_pos, -1, Vector2i(0, 0), 0)	
							set_cell(1, Vector2i(tile_pos.x-1, tile_pos.y), hovertile_type, Vector2i(0, 0), 0)
							set_cell(1, Vector2i(tile_pos.x+1, tile_pos.y), hovertile_type, Vector2i(0, 0), 0)
							set_cell(1, Vector2i(tile_pos.x, tile_pos.y-1), hovertile_type, Vector2i(0, 0), 0)
							set_cell(1, Vector2i(tile_pos.x, tile_pos.y+1), hovertile_type, Vector2i(0, 0), 0)

						if unit_type == "Ranged":
							var hoverflag_1 = true															
							for j in 15:	
								set_cell(1, tile_pos, -1, Vector2i(0, 0), 0)
								if hoverflag_1 == true:
									for k in structureArray.size():
										if tile_pos.x-j >= 0:
											set_cell(1, Vector2i(tile_pos.x-j, tile_pos.y), hovertile_type, Vector2i(0, 0), 0)
											if structureCoord[k] == Vector2i(tile_pos.x-j, tile_pos.y):
												hoverflag_1 = false
												set_cell(1, Vector2i(tile_pos.x-j, tile_pos.y), -1, Vector2i(0, 0), 0)	
												break	
									
							var hoverflag_2 = true										
							for j in 15:	
								set_cell(1, tile_pos, -1, Vector2i(0, 0), 0)
								if hoverflag_2 == true:											
									for k in structureArray.size():																						
										if tile_pos.y+j <= 15:
											set_cell(1, Vector2i(tile_pos.x, tile_pos.y+j), hovertile_type, Vector2i(0, 0), 0)
											if structureCoord[k] == Vector2i(tile_pos.x, tile_pos.y+j):
												hoverflag_2 = false
												set_cell(1, Vector2i(tile_pos.x, tile_pos.y+j), -1, Vector2i(0, 0), 0)
												break

							var hoverflag_3 = true	
							for j in 15:	
								set_cell(1, tile_pos, -1, Vector2i(0, 0), 0)
								if hoverflag_3 == true:											
									for k in structureArray.size():																													
										if tile_pos.x+j <= 15:
											set_cell(1, Vector2i(tile_pos.x+j, tile_pos.y), hovertile_type, Vector2i(0, 0), 0)
											if structureCoord[k] == Vector2i(tile_pos.x+j, tile_pos.y):
												hoverflag_3 = false
												set_cell(1, Vector2i(tile_pos.x+j, tile_pos.y), -1, Vector2i(0, 0), 0)
												break

							var hoverflag_4 = true	
							for j in 15:	
								set_cell(1, tile_pos, -1, Vector2i(0, 0), 0)
								if hoverflag_4 == true:											
									for k in structureArray.size():																											
										if tile_pos.y-j >= 0:									
											set_cell(1, Vector2i(tile_pos.x, tile_pos.y-j), hovertile_type, Vector2i(0, 0), 0)
											if structureCoord[k] == Vector2i(tile_pos.x, tile_pos.y-j):
												hoverflag_4 = false
												set_cell(1, Vector2i(tile_pos.x, tile_pos.y-j), -1, Vector2i(0, 0), 0)
												break

						
			if tile_pos.x == 0:
				set_cell(1, Vector2i(tile_pos.x-1, tile_pos.y), -1, Vector2i(0, 0), 0)
			if tile_pos.y == 0:
				set_cell(1, Vector2i(tile_pos.x, tile_pos.y-1), -1, Vector2i(0, 0), 0)							
			if tile_pos.x == 15:
				set_cell(1, Vector2i(tile_pos.x+1, tile_pos.y), -1, Vector2i(0, 0), 0)
			if tile_pos.y == 15:
				set_cell(1, Vector2i(tile_pos.x, tile_pos.y+1), -1, Vector2i(0, 0), 0)	



