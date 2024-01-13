extends Node2D

var rng = RandomNumberGenerator.new()
var _int = [0, 1, 2, 3, 4, 5, 6 ,7, 8, 9]
var _int_full = []
var available_units = []
var CPU_units = []
var USER_units = []

var random_user_unit = 0
var random_cpu_unit = 0

var team_1 = []
var team_2 = []

var score_1
var score_2

var arrays_set = false

@export var node2D: Node2D

var M1 = preload("res://scenes/mek/M1.scn")
var M2 = preload("res://scenes/mek/M2.scn")
var M3 = preload("res://scenes/mek/M3.scn")
var R1 = preload("res://scenes/mek/R1.scn")
var R2 = preload("res://scenes/mek/R2.scn")
var R3 = preload("res://scenes/mek/R3.scn")
var R4 = preload("res://scenes/mek/R4.scn")
var S1 = preload("res://scenes/mek/S1.scn")
var S2 = preload("res://scenes/mek/S2.scn")
var S3 = preload("res://scenes/mek/S3.scn")

var structures: Array[Area2D]

var stored_cells = []
var team_two = []

# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("../TurnManager").user_turn_started.connect(on_user_turn_started)
	get_node("../TurnManager").cpu_turn_started.connect(on_cpu_turn_started)
	get_node("../TurnStack").turn_over.connect(on_turn_over)
	get_node("../TurnManager").start()

	await get_tree().create_timer(0).timeout
	spawn_meks()
	
	await get_tree().create_timer(0).timeout
	team_arrays()	
	
	# Randomize units at start	
	for i in get_node("../BattleManager").available_units.size():
		while true:
			var my_random_tile_x = rng.randi_range(1, 14)
			var my_random_tile_y = rng.randi_range(1, 14)
			var tile_pos = Vector2i(my_random_tile_x, my_random_tile_y)
			var tile_center_pos = get_node("../TileMap").map_to_local(tile_pos) + Vector2(0,0) / 2
			var ontile = false
			for j in node2D.structures.size():
				for k in get_node("../BattleManager").available_units.size():
					if k != i and get_node("../TileMap").unitsCoord[k] == tile_pos or node2D.structures[j].position == tile_center_pos:		
						ontile = true					
			if !ontile: 
				get_node("../TileMap").unitsCoord[i] = tile_pos
				get_node("../BattleManager").available_units[i].position = tile_center_pos
				get_node("../BattleManager").available_units[i].z_index = tile_pos.x + tile_pos.y					
				break
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	available_units = get_tree().get_nodes_in_group("mek_scenes")	

func _input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_SPACE:
			get_node("../TurnManager").cpu_turn_started.emit()
		if event.pressed and event.keycode == KEY_ESCAPE:
			get_tree().quit()
				
func on_user_turn_started() -> void:
	print("USER turn")
	print('awaiting action')
	await get_node("../TileMap").unit_used_turn == true
	print('USER acted')
	await get_tree().create_timer(0.1).timeout
	get_node("../TurnManager").cpu_turn_started.emit()
	
func on_cpu_turn_started() -> void:
	available_units = get_tree().get_nodes_in_group("mek_scenes")
		
	if get_node("../BattleManager").available_units[random_cpu_unit].unit_status == "Inactive" or get_node("../BattleManager").available_units[random_user_unit].unit_status == "Inactive":
		print("Try UNIT again.")
		get_node("../TurnManager").cpu_turn_started.emit()
		return

	#Remove hover tiles										
	for j in 16:
		for k in 16:
			get_node("../TileMap").set_cell(1, Vector2i(j,k), -1, Vector2i(0, 0), 0)		
	
	print('CPU turn')
	get_node("../TileMap").moving = true	
	
	for i in available_units.size():
		if available_units[i].unit_team == 2:
			available_units[i].add_to_group("CPU_Team")
		if available_units[i].unit_team == 1:
			available_units[i].add_to_group("USER_Team")
				
	CPU_units = get_tree().get_nodes_in_group("CPU_Team")
	USER_units = get_tree().get_nodes_in_group("USER_Team")	

	for n in USER_units.size():				
		var unit_target_pos = get_node("../TileMap").local_to_map(get_node("../BattleManager").CPU_units[n].position)
		var surrounding_cells = get_node("../TileMap").get_surrounding_cells(unit_target_pos)
		var random_cell = rng.randi_range(0, 3)				
		if get_node("../BattleManager").CPU_units[n].unit_movement == 1:
			for k in surrounding_cells.size():
				get_node("../TileMap").set_cell(1, Vector2i(surrounding_cells[k].x, surrounding_cells[k].y), 18, Vector2i(0, 0), 0)
				if surrounding_cells[k].x <= -1 or surrounding_cells[k].y >= 16 or surrounding_cells[k].x >= 16 or surrounding_cells[k].y <= -1:
					get_node("../TileMap").set_cell(1, Vector2i(surrounding_cells[k].x, surrounding_cells[k].y), -1, Vector2i(0, 0), 0)						
		if get_node("../BattleManager").CPU_units[n].unit_movement == 2:
			for k in surrounding_cells.size():
				get_node("../TileMap").set_cell(1, Vector2i(surrounding_cells[k].x, surrounding_cells[k].y), 18, Vector2i(0, 0), 0)															
				if surrounding_cells[k].x <= -1 or surrounding_cells[k].y >= 16 or surrounding_cells[k].x >= 16 or surrounding_cells[k].y <= -1:
					get_node("../TileMap").set_cell(1, Vector2i(surrounding_cells[k].x, surrounding_cells[k].y), -1, Vector2i(0, 0), 0)								
			for k in surrounding_cells.size():
				get_node("../TileMap").set_cell(1, Vector2i(surrounding_cells[k].x+1, surrounding_cells[k].y), 18, Vector2i(0, 0), 0)																																								
				get_node("../TileMap").set_cell(1, Vector2i(surrounding_cells[k].x-1, surrounding_cells[k].y), 18, Vector2i(0, 0), 0)															
				get_node("../TileMap").set_cell(1, Vector2i(surrounding_cells[k].x, surrounding_cells[k].y+1), 18, Vector2i(0, 0), 0)																																								
				get_node("../TileMap").set_cell(1, Vector2i(surrounding_cells[k].x, surrounding_cells[k].y-1), 18, Vector2i(0, 0), 0)									
		if get_node("../BattleManager").CPU_units[n].unit_movement == 3:
			for k in surrounding_cells.size():
				get_node("../TileMap").set_cell(1, Vector2i(surrounding_cells[k].x, surrounding_cells[k].y), 18, Vector2i(0, 0), 0)														
				if surrounding_cells[k].x <= -1 or surrounding_cells[k].y >= 16 or surrounding_cells[k].x >= 16 or surrounding_cells[k].y <= -1:
					get_node("../TileMap").set_cell(1, Vector2i(surrounding_cells[k].x, surrounding_cells[k].y), -1, Vector2i(0, 0), 0)								
			for k in surrounding_cells.size():
				get_node("../TileMap").set_cell(1, Vector2i(surrounding_cells[k].x+1, surrounding_cells[k].y), 18, Vector2i(0, 0), 0)																																								
				get_node("../TileMap").set_cell(1, Vector2i(surrounding_cells[k].x-1, surrounding_cells[k].y), 18, Vector2i(0, 0), 0)															
				get_node("../TileMap").set_cell(1, Vector2i(surrounding_cells[k].x, surrounding_cells[k].y+1), 18, Vector2i(0, 0), 0)																																								
				get_node("../TileMap").set_cell(1, Vector2i(surrounding_cells[k].x, surrounding_cells[k].y-1), 18, Vector2i(0, 0), 0)													
			for k in surrounding_cells.size():
				get_node("../TileMap").set_cell(1, Vector2i(surrounding_cells[k].x+2, surrounding_cells[k].y), 18, Vector2i(0, 0), 0)																																								
				get_node("../TileMap").set_cell(1, Vector2i(surrounding_cells[k].x-2, surrounding_cells[k].y), 18, Vector2i(0, 0), 0)															
				get_node("../TileMap").set_cell(1, Vector2i(surrounding_cells[k].x, surrounding_cells[k].y+2), 18, Vector2i(0, 0), 0)																																								
				get_node("../TileMap").set_cell(1, Vector2i(surrounding_cells[k].x, surrounding_cells[k].y-2), 18, Vector2i(0, 0), 0)						
		if get_node("../BattleManager").CPU_units[n].unit_movement == 4:
			for k in surrounding_cells.size():
				get_node("../TileMap").set_cell(1, Vector2i(surrounding_cells[k].x, surrounding_cells[k].y), 18, Vector2i(0, 0), 0)									
				if surrounding_cells[k].x <= -1 or surrounding_cells[k].y >= 16 or surrounding_cells[k].x >= 16 or surrounding_cells[k].y <= -1:
					get_node("../TileMap").set_cell(1, Vector2i(surrounding_cells[k].x, surrounding_cells[k].y), -1, Vector2i(0, 0), 0)											
			for k in surrounding_cells.size():
				get_node("../TileMap").set_cell(1, Vector2i(surrounding_cells[k].x+1, surrounding_cells[k].y), 18, Vector2i(0, 0), 0)																																								
				get_node("../TileMap").set_cell(1, Vector2i(surrounding_cells[k].x-1, surrounding_cells[k].y), 18, Vector2i(0, 0), 0)															
				get_node("../TileMap").set_cell(1, Vector2i(surrounding_cells[k].x, surrounding_cells[k].y+1), 18, Vector2i(0, 0), 0)																																								
				get_node("../TileMap").set_cell(1, Vector2i(surrounding_cells[k].x, surrounding_cells[k].y-1), 18, Vector2i(0, 0), 0)																					
			for k in surrounding_cells.size():
				get_node("../TileMap").set_cell(1, Vector2i(surrounding_cells[k].x+2, surrounding_cells[k].y), 18, Vector2i(0, 0), 0)																																								
				get_node("../TileMap").set_cell(1, Vector2i(surrounding_cells[k].x-2, surrounding_cells[k].y), 18, Vector2i(0, 0), 0)															
				get_node("../TileMap").set_cell(1, Vector2i(surrounding_cells[k].x, surrounding_cells[k].y+2), 18, Vector2i(0, 0), 0)																																								
				get_node("../TileMap").set_cell(1, Vector2i(surrounding_cells[k].x, surrounding_cells[k].y-2), 18, Vector2i(0, 0), 0)																						
			for k in surrounding_cells.size():
				get_node("../TileMap").set_cell(1, Vector2i(surrounding_cells[k].x+3, surrounding_cells[k].y), 18, Vector2i(0, 0), 0)																																								
				get_node("../TileMap").set_cell(1, Vector2i(surrounding_cells[k].x-3, surrounding_cells[k].y), 18, Vector2i(0, 0), 0)															
				get_node("../TileMap").set_cell(1, Vector2i(surrounding_cells[k].x, surrounding_cells[k].y+3), 18, Vector2i(0, 0), 0)																																								
				get_node("../TileMap").set_cell(1, Vector2i(surrounding_cells[k].x, surrounding_cells[k].y-3), 18, Vector2i(0, 0), 0)	
			
			get_node("../TileMap").set_cell(1, Vector2i(unit_target_pos.x+2, unit_target_pos.y+2), 18, Vector2i(0, 0), 0)																																								
			get_node("../TileMap").set_cell(1, Vector2i(unit_target_pos.x-2, unit_target_pos.y-2), 18, Vector2i(0, 0), 0)															
			get_node("../TileMap").set_cell(1, Vector2i(unit_target_pos.x+2, unit_target_pos.y-2), 18, Vector2i(0, 0), 0)																																								
			get_node("../TileMap").set_cell(1, Vector2i(unit_target_pos.x-2, unit_target_pos.y+2), 18, Vector2i(0, 0), 0)
		
		for m in USER_units.size():
			var user_pos = get_node("../TileMap").local_to_map(USER_units[m].position)
			if get_node("../TileMap").get_cell_source_id(1, user_pos) == 18:
				print("Praise Jesus!")

				var surrounding_cells_array = get_node("../TileMap").get_surrounding_cells(user_pos)
				var target_random_cell = rng.randi_range(0, 3)
				# Find Path
				var patharray = get_node("../TileMap").astar_grid.get_point_path(unit_target_pos, surrounding_cells_array[target_random_cell])
				
				# Set hover cells
				for h in patharray.size():
					await get_tree().create_timer(0.01).timeout
					get_node("../TileMap").set_cell(1, patharray[h], 18, Vector2i(0, 0), 0)	
				
				get_node("../TileMap").hovertile.hide()
				get_node("../BattleManager").CPU_units[n].get_child(0).play("move")
				
				# Move unit		
				for h in patharray.size():
					var tile_center_pos = get_node("../TileMap").map_to_local(patharray[h]) + Vector2(0,0) / 2
					var tween = create_tween()
					var cpu_unit_pos = get_node("../TileMap").local_to_map(get_node("../BattleManager").CPU_units[n].position)
					get_node("../BattleManager").CPU_units[n].z_index = cpu_unit_pos.x + cpu_unit_pos.y		
					tween.tween_property(get_node("../BattleManager").CPU_units[n], "position", tile_center_pos, 0.35)				
					get_node("../TileMap").get_child(1).stream = get_node("../TileMap").map_sfx[2]
					get_node("../TileMap").get_child(1).play()	
					await get_tree().create_timer(0.35).timeout
			
			
		#Erase hover tiles
		for j in 16:
			for k in 16:
				get_node("../TileMap").set_cell(1, Vector2i(j,k), -1, Vector2i(0, 0), 0)

		get_node("../BattleManager").CPU_units[n].get_child(0).play("default")

		for m in USER_units.size():
			#Attacks
			for p in 4:
				if get_node("../TileMap").local_to_map(USER_units[m].position) == surrounding_cells[p]:
					var attack_center_pos = get_node("../TileMap").map_to_local(get_node("../TileMap").local_to_map(USER_units[m].position)) + Vector2(0,0) / 2	
					
					if CPU_units[n].scale.x == 1 and CPU_units[n].position.x > attack_center_pos.x:
						CPU_units[n].scale.x = 1
						#print("1")
					elif CPU_units[n].scale.x == -1 and CPU_units[n].position.x < attack_center_pos.x:
						CPU_units[n].scale.x = -1
						#print("2")	
					if CPU_units[n].scale.x == -1 and CPU_units[n].position.x > attack_center_pos.x:
						CPU_units[n].scale.x = 1
						#print("3")
					elif CPU_units[n].scale.x == 1 and CPU_units[n].position.x < attack_center_pos.x:
						CPU_units[n].scale.x = -1
						#print("4")																																				
																																
					
					CPU_units[n].get_child(0).play("attack")
					
					var sfx
					
					if CPU_units[n].unit_name == "Pantherbot":
						sfx = 5
					else:
						sfx = 4
						
					get_node("../TileMap").get_child(1).stream = get_node("../TileMap").map_sfx[sfx]
					get_node("../TileMap").get_child(1).play()		
									
					await get_tree().create_timer(0.5).timeout
					CPU_units[n].get_child(0).play("default")
								
					var _bumpedvector = get_node("../TileMap").local_to_map(USER_units[n].position)
					
					get_node("../Camera2D").shake(0.5, 30, 3)
					
					get_node("../TileMap").get_child(1).stream = get_node("../TileMap").map_sfx[3]
					get_node("../TileMap").get_child(1).play()	
					return	
			

func on_turn_over() -> void:
	get_node("../TurnManager").advance_turn()
	
func get_random():
	_int = _int_full.duplicate()
	_int.shuffle()
	var random_int = _int.pop_front()
	return random_int	
	
func team_arrays():
	randomize()
	get_node("../BattleManager").available_units.shuffle()
		
	for i in available_units.size():
		available_units[i].unit_num = i
		
	for i in available_units.size():
		if i <= 4:
			available_units[i].unit_team = 1
		else:
			available_units[i].unit_team = 2			
	
	for i in available_units.size():
		if available_units[i].unit_team == 1:
			# Team color
			get_node("../BattleManager").available_units[i].get_child(0).modulate = Color8(255, 255, 255)
			get_node("../BattleManager").available_units[i].unit_level = 2
			get_node("../BattleManager").available_units[i].unit_attack = 2
			get_node("../BattleManager").available_units[i].unit_defence = 2
			
		elif available_units[i].unit_team == 2:
				# Team color
				get_node("../BattleManager").available_units[i].get_child(0).modulate = Color8(255, 110, 255)
				get_node("../BattleManager").available_units[i].unit_level = 2
				get_node("../BattleManager").available_units[i].unit_attack = 2
				get_node("../BattleManager").available_units[i].unit_defence = 2
			
										
	arrays_set = true
	
func spawn_meks():
	var R1_inst = R1.instantiate()
	node2D.add_child(R1_inst)
	R1_inst.add_to_group("mek_scenes")

	var R2_inst = R2.instantiate()
	node2D.add_child(R2_inst)
	R2_inst.add_to_group("mek_scenes")

	var R3_inst = R3.instantiate()
	node2D.add_child(R3_inst)
	R3_inst.add_to_group("mek_scenes")
	
	var R4_inst = R4.instantiate()
	node2D.add_child(R4_inst)
	R4_inst.add_to_group("mek_scenes")
			
	var S1_inst = S1.instantiate()
	node2D.add_child(S1_inst)
	S1_inst.add_to_group("mek_scenes")

	var S2_inst = S2.instantiate()
	node2D.add_child(S2_inst)
	S2_inst.add_to_group("mek_scenes")

	var S3_inst = S3.instantiate()
	node2D.add_child(S3_inst)
	S3_inst.add_to_group("mek_scenes")

	var M1_inst = M1.instantiate()
	node2D.add_child(M1_inst)
	M1_inst.add_to_group("mek_scenes")

	var M2_inst = M2.instantiate()
	node2D.add_child(M2_inst)
	M2_inst.add_to_group("mek_scenes")

	var M3_inst = M3.instantiate()
	node2D.add_child(M3_inst)
	M3_inst.add_to_group("mek_scenes")
	
	available_units = get_tree().get_nodes_in_group("mek_scenes")		
	
