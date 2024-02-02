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
@export var right_clicked_unit: Area2D
@export var unit_type: String

signal unit_used_turn

@export var only_once : bool = true
@export var only_once_structures : bool = true

@export var map_sfx: Array[AudioStream]
@export var node2D: Node2D

var moves_counter = 0;

var structures: Array[Area2D]
var buildings = []
var towers = []
var stadiums = []
var districts = []

@onready var line_2d = $"../Line2D"
@onready var post_a = $"../postA"
@onready var pre_b = $"../preB"
@onready var sprite_2d = $"../Sprite2D"

var camera_target: int
var obj_loc 
var surrounding_cells
var users_active

# Called when the node enters the scene tree for the first time.
func _ready():	
	pass		
				
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
		
	for i in structures.size():
		var structure_pos = local_to_map(structures[i].position)
		astar_grid.set_point_solid(structure_pos, true)	
	
	for i in get_node("../BattleManager").available_units.size():
		var unit_pos = local_to_map(get_node("../BattleManager").available_units[i].position)
		unitsCoord[i] = unit_pos
		get_node("../TileMap").astar_grid.set_point_solid(unit_pos, true)
		
	for i in get_node("../BattleManager").available_units.size():
		var unit_pos = local_to_map(get_node("../BattleManager").available_units[i].position)
		unitsCoord_1[i] = unit_pos
		#get_node("../TileMap").astar_grid.set_point_solid(unit_pos, true)
		
	for i in get_node("../BattleManager").available_units.size():
		var unit_pos = local_to_map(get_node("../BattleManager").available_units[i].position)
		unitsCoord_2[i] = unit_pos	
		#get_node("../TileMap").astar_grid.set_point_solid(unit_pos, true)				

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
	
	#Remove tiles that are on the corner grids off map
	for h in 16:
		for i in 16:
			set_cell(1, Vector2i(-h-1, -i-1), -1, Vector2i(0, 0), 0)
	for h in 16:
		for i in 16:
			set_cell(1, Vector2i(h+16, -i-1), -1, Vector2i(0, 0), 0)
	for h in 16:
		for i in 16:
			set_cell(1, Vector2i(-h-1, i+16), -1, Vector2i(0, 0), 0)
	for h in 16:
		for i in 16:
			set_cell(1, Vector2i(h+16, i+16), -1, Vector2i(0, 0), 0)	
			
	for i in structures.size():
		var structure_pos = local_to_map(structures[i].position)
		structureCoord[i] = structure_pos		

	for i in get_node("../BattleManager").available_units.size():
		if get_node("../BattleManager").available_units[i].unit_team == 1 and get_node("../BattleManager").available_units[i].unit_status == "Active":
			get_node("../BattleManager").available_units[i].add_to_group("USER Active")
		
	users_active = get_tree().get_nodes_in_group("USER Active")		
	get_node("../Control").get_child(18).text = str(moves_counter) + " / " + str((users_active.size()-get_node("../BattleManager").inactive_total_user.size())*2)																	#

		
func _input(event):			
	if event is InputEventKey:	
		if event.pressed and event.keycode == KEY_3:
			for i in structures.size():
				get_node("../TileMap").structures[i].get_child(0).play("demolished")
				get_node("../TileMap").structures[i].get_child(0).modulate = Color8(255, 255, 255) 	
						
	# Click and drag to move unit	
	if event is InputEventMouseButton and moving == false and get_node("../BattleManager").spawning == false:			
		if event.button_index == MOUSE_BUTTON_LEFT and hovertile.offset.y == 0:							
			var mouse_pos = get_global_mouse_position()
			var tile_pos = local_to_map(mouse_pos)	
			var tile_data = get_cell_tile_data(0, tile_pos)
			
			clicked_pos = tile_pos						
																							
			# Ranged Attack
			if only_once:
				for h in get_node("../BattleManager").available_units.size():					
					var clicked_center_pos = map_to_local(clicked_pos) + Vector2(0,0) / 2
						
					if clicked_center_pos == get_node("../BattleManager").available_units[h].position and get_cell_source_id(1, tile_pos) == 48 and right_clicked_unit.unit_type == "Ranged" and get_node("../BattleManager").available_units[h].attacked == false:
						only_once = false
						
						var attack_center_pos = map_to_local(clicked_pos) + Vector2(0,0) / 2	
						
						if right_clicked_unit.scale.x == 1 and right_clicked_unit.position.x > attack_center_pos.x:
							right_clicked_unit.scale.x = 1
						
						elif right_clicked_unit.scale.x == -1 and right_clicked_unit.position.x < attack_center_pos.x:
							right_clicked_unit.scale.x = -1	
						
						if right_clicked_unit.scale.x == -1 and right_clicked_unit.position.x > attack_center_pos.x:
							right_clicked_unit.scale.x = 1
						
						elif right_clicked_unit.scale.x == 1 and right_clicked_unit.position.x < attack_center_pos.x:
							right_clicked_unit.scale.x = -1																																					
												
						right_clicked_unit.get_child(0).play("attack")	
						
						if right_clicked_unit.unit_team == 1:
							right_clicked_unit.attacked = true	
							right_clicked_unit.attacked = true	
						
						await get_tree().create_timer(0.5).timeout
						right_clicked_unit.get_child(0).play("default")		
						
						var _bumpedvector = clicked_pos
						var right_clicked_pos = local_to_map(right_clicked_unit.position)
						
						get_node("../Camera2D").shake(0.5, 30, 3)
						
						get_child(1).stream = map_sfx[3]
						get_child(1).play()	
						
						await SetLinePoints(line_2d, right_clicked_unit.get_node("Emitter").global_position, Vector2(0,0), Vector2(0,0), get_node("../BattleManager").available_units[h].get_node("Emitter").global_position)
						get_node("../BattleManager").available_units[h].get_child(0).set_offset(Vector2(0,0))
													
						if right_clicked_pos.y < clicked_pos.y and right_clicked_unit.position.x > attack_center_pos.x:	
							var tile_center_pos = map_to_local(Vector2i(_bumpedvector.x, _bumpedvector.y+1)) + Vector2(0,0) / 2
							get_node("../TileMap").get_node("../BattleManager").available_units[h].position = clicked_pos
							unitsCoord_2[h] = tile_pos										
							unitsCoord_2[h] = Vector2i(_bumpedvector.x, _bumpedvector.y+1)
							get_node("../BattleManager").available_units[h].position = tile_center_pos	
							var unit_pos = local_to_map(get_node("../BattleManager").available_units[h].position)										
							get_node("../BattleManager").available_units[h].z_index = unit_pos.x + unit_pos.y	
							var tween: Tween = create_tween()
							tween.tween_property(get_node("../BattleManager").available_units[h], "modulate:v", 1, 0.50).from(5)
							#await get_tree().create_timer(1).timeout
							get_node("../BattleManager").available_units[h].unit_min -= right_clicked_unit.unit_level
							right_clicked_unit.xp += 1
							get_node("../BattleManager").available_units[h].progressbar.set_value(get_node("../BattleManager").available_units[h].unit_min)
							#get_node("../TurnManager").cpu_turn_started.emit()
							get_node("../BattleManager").check_health_now()
							moves_counter += 1
							 

						if right_clicked_pos.y > clicked_pos.y and right_clicked_unit.position.x < attack_center_pos.x:								
							var tile_center_pos = map_to_local(Vector2i(_bumpedvector.x, _bumpedvector.y-1)) + Vector2(0,0) / 2
							get_node("../TileMap").get_node("../BattleManager").available_units[h].position = clicked_pos
							unitsCoord_2[h] = tile_pos										
							unitsCoord_2[h] = Vector2i(_bumpedvector.x, _bumpedvector.y-1)
							get_node("../BattleManager").available_units[h].position = tile_center_pos	
							var unit_pos = local_to_map(get_node("../BattleManager").available_units[h].position)										
							get_node("../BattleManager").available_units[h].z_index = unit_pos.x + unit_pos.y
							var tween: Tween = create_tween()
							tween.tween_property(get_node("../BattleManager").available_units[h], "modulate:v", 1, 0.50).from(5)										
							#await get_tree().create_timer(1).timeout
							get_node("../BattleManager").available_units[h].unit_min -= right_clicked_unit.unit_level
							right_clicked_unit.xp += 1
							get_node("../BattleManager").available_units[h].progressbar.set_value(get_node("../BattleManager").available_units[h].unit_min)				
							#get_node("../TurnManager").cpu_turn_started.emit()
							moves_counter += 1
							get_node("../BattleManager").check_health_now()
	
						if right_clicked_pos.x > clicked_pos.x and right_clicked_unit.position.x > attack_center_pos.x:	
							var tile_center_pos = map_to_local(Vector2i(_bumpedvector.x-1, _bumpedvector.y)) + Vector2(0,0) / 2										
							get_node("../TileMap").get_node("../BattleManager").available_units[h].position = clicked_pos
							unitsCoord_2[h] = tile_pos										
							unitsCoord_2[h] = Vector2i(_bumpedvector.x-1, _bumpedvector.y)
							get_node("../BattleManager").available_units[h].position = tile_center_pos	
							var unit_pos = local_to_map(get_node("../BattleManager").available_units[h].position)										
							get_node("../BattleManager").available_units[h].z_index = unit_pos.x + unit_pos.y
							var tween: Tween = create_tween()
							tween.tween_property(get_node("../BattleManager").available_units[h], "modulate:v", 1, 0.50).from(5)	
							#await get_tree().create_timer(1).timeout
							get_node("../BattleManager").available_units[h].unit_min -= right_clicked_unit.unit_level
							right_clicked_unit.xp += 1
							get_node("../BattleManager").available_units[h].progressbar.set_value(get_node("../BattleManager").available_units[h].unit_min)
							#get_node("../TurnManager").cpu_turn_started.emit()
							moves_counter += 1
							get_node("../BattleManager").check_health_now()
						
						if right_clicked_pos.x < clicked_pos.x and right_clicked_unit.position.x < attack_center_pos.x:
							var tile_center_pos = map_to_local(Vector2i(_bumpedvector.x+1, _bumpedvector.y)) + Vector2(0,0) / 2
							get_node("../TileMap").get_node("../BattleManager").available_units[h].position = clicked_pos
							unitsCoord_2[h] = tile_pos										
							unitsCoord_2[h] = Vector2i(_bumpedvector.x+1, _bumpedvector.y)
							get_node("../BattleManager").available_units[h].position = tile_center_pos	
							var unit_pos = local_to_map(get_node("../BattleManager").available_units[h].position)										
							get_node("../BattleManager").available_units[h].z_index = unit_pos.x + unit_pos.y		
							var tween: Tween = create_tween()
							tween.tween_property(get_node("../BattleManager").available_units[h], "modulate:v", 1, 0.50).from(5)
							#await get_tree().create_timer(1).timeout
							get_node("../BattleManager").available_units[h].unit_min -= right_clicked_unit.unit_level
							right_clicked_unit.xp += 1
							get_node("../BattleManager").available_units[h].progressbar.set_value(get_node("../BattleManager").available_units[h].unit_min)
							#get_node("../TurnManager").cpu_turn_started.emit()
							moves_counter += 1
							get_node("../BattleManager").check_health_now()
							
						only_once = true
								
			get_node("../BattleManager").check_health_now()
			
			#Place hover tiles		
			if tile_data is TileData:			
				for i in get_node("../BattleManager").available_units.size():
					var unit_pos = local_to_map(get_node("../BattleManager").available_units[i].position)
					if unit_pos == tile_pos and get_node("../BattleManager").available_units[i].moved == false and get_node("../BattleManager").available_units[i].attacked == false:
						hovertile.set_offset(Vector2(0,-10))
						get_node("../BattleManager").available_units[i].get_child(0).set_offset(Vector2(0,-10))
						clicked_unit = get_node("../BattleManager").available_units[i].unit_num
						get_child(1).stream = map_sfx[0]
						get_child(1).play()
														
						for j in get_node("../BattleManager").available_units[i].unit_movement:
							var surrounding_cells = get_node("../TileMap").get_surrounding_cells(unit_pos)
							
							if get_node("../BattleManager").available_units[i].unit_movement == 1:
								for k in surrounding_cells.size():
									set_cell(1, tile_pos, -1, Vector2i(0, 0), 0)
									set_cell(1, Vector2i(surrounding_cells[k].x, surrounding_cells[k].y), 18, Vector2i(0, 0), 0)
									if surrounding_cells[k].x <= -1 or surrounding_cells[k].y >= 16 or surrounding_cells[k].x >= 16 or surrounding_cells[k].y <= -1:
										set_cell(1, tile_pos, -1, Vector2i(0, 0), 0)
										set_cell(1, Vector2i(surrounding_cells[k].x, surrounding_cells[k].y), -1, Vector2i(0, 0), 0)										
							
							if get_node("../BattleManager").available_units[i].unit_movement == 2:
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
							
							if get_node("../BattleManager").available_units[i].unit_movement == 3:
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

							if get_node("../BattleManager").available_units[i].unit_movement == 4:
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
								for k in surrounding_cells.size():
									set_cell(1, tile_pos, -1, Vector2i(0, 0), 0)
									set_cell(1, Vector2i(surrounding_cells[k].x+3, surrounding_cells[k].y), 18, Vector2i(0, 0), 0)																																								
									set_cell(1, Vector2i(surrounding_cells[k].x-3, surrounding_cells[k].y), 18, Vector2i(0, 0), 0)															
									set_cell(1, Vector2i(surrounding_cells[k].x, surrounding_cells[k].y+3), 18, Vector2i(0, 0), 0)																																								
									set_cell(1, Vector2i(surrounding_cells[k].x, surrounding_cells[k].y-3), 18, Vector2i(0, 0), 0)	
									
								set_cell(1, tile_pos, -1, Vector2i(0, 0), 0)
								set_cell(1, Vector2i(unit_pos.x+2, unit_pos.y+2), 18, Vector2i(0, 0), 0)																																								
								set_cell(1, Vector2i(unit_pos.x-2, unit_pos.y-2), 18, Vector2i(0, 0), 0)															
								set_cell(1, Vector2i(unit_pos.x+2, unit_pos.y-2), 18, Vector2i(0, 0), 0)																																								
								set_cell(1, Vector2i(unit_pos.x-2, unit_pos.y+2), 18, Vector2i(0, 0), 0)			

							if get_node("../BattleManager").available_units[i].unit_movement == 5:
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
								for k in surrounding_cells.size():
									set_cell(1, tile_pos, -1, Vector2i(0, 0), 0)
									set_cell(1, Vector2i(surrounding_cells[k].x+3, surrounding_cells[k].y), 18, Vector2i(0, 0), 0)																																								
									set_cell(1, Vector2i(surrounding_cells[k].x-3, surrounding_cells[k].y), 18, Vector2i(0, 0), 0)															
									set_cell(1, Vector2i(surrounding_cells[k].x, surrounding_cells[k].y+3), 18, Vector2i(0, 0), 0)																																								
									set_cell(1, Vector2i(surrounding_cells[k].x, surrounding_cells[k].y-3), 18, Vector2i(0, 0), 0)	
								for k in surrounding_cells.size():
									set_cell(1, tile_pos, -1, Vector2i(0, 0), 0)
									set_cell(1, Vector2i(surrounding_cells[k].x+4, surrounding_cells[k].y), 18, Vector2i(0, 0), 0)																																								
									set_cell(1, Vector2i(surrounding_cells[k].x-4, surrounding_cells[k].y), 18, Vector2i(0, 0), 0)															
									set_cell(1, Vector2i(surrounding_cells[k].x, surrounding_cells[k].y+4), 18, Vector2i(0, 0), 0)																																								
									set_cell(1, Vector2i(surrounding_cells[k].x, surrounding_cells[k].y-4), 18, Vector2i(0, 0), 0)	
																		
								set_cell(1, tile_pos, -1, Vector2i(0, 0), 0)
								set_cell(1, Vector2i(unit_pos.x+2, unit_pos.y+2), 18, Vector2i(0, 0), 0)																																								
								set_cell(1, Vector2i(unit_pos.x-2, unit_pos.y-2), 18, Vector2i(0, 0), 0)															
								set_cell(1, Vector2i(unit_pos.x+2, unit_pos.y-2), 18, Vector2i(0, 0), 0)																																								
								set_cell(1, Vector2i(unit_pos.x-2, unit_pos.y+2), 18, Vector2i(0, 0), 0)	

								set_cell(1, tile_pos, -1, Vector2i(0, 0), 0)
								set_cell(1, Vector2i(unit_pos.x+2, unit_pos.y+3), 18, Vector2i(0, 0), 0)																																								
								set_cell(1, Vector2i(unit_pos.x-3, unit_pos.y-2), 18, Vector2i(0, 0), 0)															
								set_cell(1, Vector2i(unit_pos.x+2, unit_pos.y-3), 18, Vector2i(0, 0), 0)																																								
								set_cell(1, Vector2i(unit_pos.x-3, unit_pos.y+2), 18, Vector2i(0, 0), 0)	

								set_cell(1, tile_pos, -1, Vector2i(0, 0), 0)
								set_cell(1, Vector2i(unit_pos.x+3, unit_pos.y+2), 18, Vector2i(0, 0), 0)																																								
								set_cell(1, Vector2i(unit_pos.x-2, unit_pos.y-3), 18, Vector2i(0, 0), 0)															
								set_cell(1, Vector2i(unit_pos.x+3, unit_pos.y-2), 18, Vector2i(0, 0), 0)																																								
								set_cell(1, Vector2i(unit_pos.x-2, unit_pos.y+3), 18, Vector2i(0, 0), 0)
																		
		# Drop unit on mouse up																					
		elif hovertile.offset.y == -10:	
			var mouse_pos = get_global_mouse_position()
			var tile_pos = local_to_map(mouse_pos)	
				
			hovertile.set_offset(Vector2(0,0))
			for i in get_node("../BattleManager").available_units.size():
				if get_node("../BattleManager").available_units[i].get_child(0).offset == (Vector2(0,-10)) and get_node("../BattleManager").available_units[i].unit_team == 1 and get_cell_source_id(1, tile_pos) == 18 and get_node("../BattleManager").available_units[i].moved == false:										
					get_node("../BattleManager").available_units[i].moved = true
					#Remove hover tiles										
					for j in grid_height:
						for k in grid_width:
							set_cell(1, Vector2i(j,k), -1, Vector2i(0, 0), 0)					
					
					get_node("../BattleManager").available_units[i].get_child(0).set_offset(Vector2(0,0))	
					dropped_pos = tile_pos
					var patharray = astar_grid.get_point_path(clicked_pos, dropped_pos)
					get_node("../BattleManager").available_units[i].get_child(0).play("move")
					
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
						tween.tween_property(get_node("../BattleManager").available_units[i], "position", tile_center_pos, 0.35)
						unitsCoord[i] = tile_pos
						var unit_pos = local_to_map(get_node("../BattleManager").available_units[i].position)
						
						get_node("../BattleManager").available_units[i].z_index = unit_pos.x + unit_pos.y
						get_child(1).stream = map_sfx[2]
						get_child(1).play()				
						await get_tree().create_timer(0.35).timeout
					
					# Remove hover cells
					for h in patharray.size():
						set_cell(1, patharray[h], -1, Vector2i(0, 0), 0)
					
					#get_node("../TurnManager").cpu_turn_started.emit()
					moves_counter += 1
					get_node("../BattleManager").check_health_now()
					
					
					# Set moving to false			
					var unit_pos = local_to_map(get_node("../BattleManager").available_units[i].position)
					get_node("../BattleManager").available_units[i].z_index = unit_pos.x + unit_pos.y													
					get_node("../BattleManager").available_units[i].get_child(0).play("default")
					
					#Remove hover tiles										
					for j in grid_height:
						for k in grid_width:
							set_cell(1, Vector2i(j,k), -1, Vector2i(0, 0), 0)				
											
					await get_tree().create_timer(1).timeout
					
					hovertile.show()
					moving = false					
					
				get_node("../BattleManager").available_units[i].get_child(0).set_offset(Vector2(0,0))
			
			#Remove hover tiles										
			for j in grid_height:
				for k in grid_width:
					set_cell(1, Vector2i(j,k), -1, Vector2i(0, 0), 0)
					
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
				for i in get_node("../BattleManager").available_units.size():
					var unit_pos = local_to_map(get_node("../BattleManager").available_units[i].position)

					if unit_pos == tile_pos and get_node("../BattleManager").available_units[i].attacked == false:
						right_clicked_unit = get_node("../BattleManager").available_units[i]
						unit_type = get_node("../BattleManager").available_units[i].unit_type
						get_node("../BattleManager").available_units[i].position = hovertile.position
						
						get_child(1).stream = map_sfx[1]
						get_child(1).play()							
						
						if unit_type == "Melee":
							set_cell(1, tile_pos, -1, Vector2i(0, 0), 0)	
							set_cell(1, Vector2i(tile_pos.x-1, tile_pos.y), 48, Vector2i(0, 0), 0)
							set_cell(1, Vector2i(tile_pos.x+1, tile_pos.y), 48, Vector2i(0, 0), 0)
							set_cell(1, Vector2i(tile_pos.x, tile_pos.y-1), 48, Vector2i(0, 0), 0)
							set_cell(1, Vector2i(tile_pos.x, tile_pos.y+1), 48, Vector2i(0, 0), 0)

						if unit_type == "Support":
							var hoverflag_1 = true															
							for j in 3:	
								set_cell(1, tile_pos, -1, Vector2i(0, 0), 0)
								if hoverflag_1 == true:
									for k in structures.size():
										if tile_pos.x-j >= 0:
											set_cell(1, Vector2i(tile_pos.x-j, tile_pos.y), 48, Vector2i(0, 0), 0)
											if structureCoord[k] == Vector2i(tile_pos.x-j, tile_pos.y):
												hoverflag_1 = false
												set_cell(1, Vector2i(tile_pos.x-j, tile_pos.y), -1, Vector2i(0, 0), 0)	
												break	
									
							var hoverflag_2 = true										
							for j in 3:	
								set_cell(1, tile_pos, -1, Vector2i(0, 0), 0)
								if hoverflag_2 == true:											
									for k in structures.size():																						
										if tile_pos.y+j <= 15:
											set_cell(1, Vector2i(tile_pos.x, tile_pos.y+j), 48, Vector2i(0, 0), 0)
											if structureCoord[k] == Vector2i(tile_pos.x, tile_pos.y+j):
												hoverflag_2 = false
												set_cell(1, Vector2i(tile_pos.x, tile_pos.y+j), -1, Vector2i(0, 0), 0)
												break

							var hoverflag_3 = true	
							for j in 3:	
								set_cell(1, tile_pos, -1, Vector2i(0, 0), 0)
								if hoverflag_3 == true:											
									for k in structures.size():																													
										if tile_pos.x+j <= 15:
											set_cell(1, Vector2i(tile_pos.x+j, tile_pos.y), 48, Vector2i(0, 0), 0)
											if structureCoord[k] == Vector2i(tile_pos.x+j, tile_pos.y):
												hoverflag_3 = false
												set_cell(1, Vector2i(tile_pos.x+j, tile_pos.y), -1, Vector2i(0, 0), 0)
												break

							var hoverflag_4 = true	
							for j in 3:	
								set_cell(1, tile_pos, -1, Vector2i(0, 0), 0)
								if hoverflag_4 == true:											
									for k in structures.size():																											
										if tile_pos.y-j >= 0:									
											set_cell(1, Vector2i(tile_pos.x, tile_pos.y-j), 48, Vector2i(0, 0), 0)
											if structureCoord[k] == Vector2i(tile_pos.x, tile_pos.y-j):
												hoverflag_4 = false
												set_cell(1, Vector2i(tile_pos.x, tile_pos.y-j), -1, Vector2i(0, 0), 0)
												break

						if unit_type == "Ranged":
							var hoverflag_1 = true															
							for j in 15:	
								set_cell(1, tile_pos, -1, Vector2i(0, 0), 0)
								if hoverflag_1 == true:
									for k in structures.size():
										if tile_pos.x-j >= 0:
											set_cell(1, Vector2i(tile_pos.x-j, tile_pos.y), 48, Vector2i(0, 0), 0)
											if structureCoord[k] == Vector2i(tile_pos.x-j, tile_pos.y):
												hoverflag_1 = false
												set_cell(1, Vector2i(tile_pos.x-j, tile_pos.y), -1, Vector2i(0, 0), 0)	
												break	
									
							var hoverflag_2 = true										
							for j in 15:	
								set_cell(1, tile_pos, -1, Vector2i(0, 0), 0)
								if hoverflag_2 == true:											
									for k in structures.size():																						
										if tile_pos.y+j <= 15:
											set_cell(1, Vector2i(tile_pos.x, tile_pos.y+j), 48, Vector2i(0, 0), 0)
											if structureCoord[k] == Vector2i(tile_pos.x, tile_pos.y+j):
												hoverflag_2 = false
												set_cell(1, Vector2i(tile_pos.x, tile_pos.y+j), -1, Vector2i(0, 0), 0)
												break

							var hoverflag_3 = true	
							for j in 15:	
								set_cell(1, tile_pos, -1, Vector2i(0, 0), 0)
								if hoverflag_3 == true:											
									for k in structures.size():																													
										if tile_pos.x+j <= 15:
											set_cell(1, Vector2i(tile_pos.x+j, tile_pos.y), 48, Vector2i(0, 0), 0)
											if structureCoord[k] == Vector2i(tile_pos.x+j, tile_pos.y):
												hoverflag_3 = false
												set_cell(1, Vector2i(tile_pos.x+j, tile_pos.y), -1, Vector2i(0, 0), 0)
												break

							var hoverflag_4 = true	
							for j in 15:	
								set_cell(1, tile_pos, -1, Vector2i(0, 0), 0)
								if hoverflag_4 == true:											
									for k in structures.size():																											
										if tile_pos.y-j >= 0:									
											set_cell(1, Vector2i(tile_pos.x, tile_pos.y-j), 48, Vector2i(0, 0), 0)
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

func SetLinePoints(line: Line2D, a: Vector2, postA: Vector2, preB: Vector2, b: Vector2):
	get_node("../Seeker").show()
	var _a = get_node("../TileMap").local_to_map(a)
	var _b = get_node("../TileMap").local_to_map(b)

	get_node("../TileMap").get_child(1).stream = get_node("../TileMap").map_sfx[8]
	get_node("../TileMap").get_child(1).play()		
	
	get_node("../Seeker").position = a
	get_node("../Seeker").z_index = (get_node("../Seeker").position.x + get_node("../Seeker").position.y) + 1000
	var tween: Tween = create_tween()
	tween.tween_property(get_node("../Seeker"), "position", b, 1).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)	
	await get_tree().create_timer(1).timeout
	
	var explosion = preload("res://prefab/vfx/explosion_area_2d.tscn")
	var explosion_instance = explosion.instantiate()
	var explosion_pos = get_node("../TileMap").map_to_local(get_node("../TileMap").sprite_2d.position) + Vector2(0,0) / 2
	
	var tile_pos = get_node("../TileMap").local_to_map(get_node("../Seeker").position)		
	explosion_instance.set_name("explosion")
	get_parent().add_child(explosion_instance)
	explosion_instance.position = get_node("../Seeker").position	
	explosion_instance.z_index = tile_pos.x + tile_pos.y
	get_node("../Camera2D").shake(1, 30, 3)	
	get_node("../Seeker").hide()		

	#Remove hover tiles										
	for j in grid_height:
		for k in grid_width:
			set_cell(1, Vector2i(j,k), -1, Vector2i(0, 0), 0)	
