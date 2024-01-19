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

#var structures: Array[Area2D]

var hoverflag_1 = true
var hoverflag_2 = true
var hoverflag_3 = true
var hoverflag_4 = true

var structure_flag1_ranged = true
var structure_flag2_ranged = true
var structure_flag3_ranged = true
var structure_flag4_ranged = true

var structure_flag1_support = true
var structure_flag2_support = true
var structure_flag3_support = true
var structure_flag4_support = true

var stored_cells = []
var team_two = []

@onready var line_2d = $"../Line2D"
@onready var post_a = $"../postA"
@onready var pre_b = $"../preB"
@onready var sprite_2d = $"../Sprite2D"

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
	get_node("../Control").get_child(19).text = "CPU TURN"
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	for i in get_node("../BattleManager").available_units.size():
		get_node("../BattleManager").available_units[i].moved = false
		get_node("../BattleManager").available_units[i].attacked = false
		get_node("../TileMap").moves_counter = 0
		
	get_node("../BattleManager").structure_flag1_ranged = true
	get_node("../BattleManager").structure_flag2_ranged = true
	get_node("../BattleManager").structure_flag3_ranged = true
	get_node("../BattleManager").structure_flag4_ranged = true
	
	get_node("../BattleManager").structure_flag1_support = true
	get_node("../BattleManager").structure_flag2_support = true
	get_node("../BattleManager").structure_flag3_support = true
	get_node("../BattleManager").structure_flag4_support = true		
			
	available_units = get_tree().get_nodes_in_group("mek_scenes")	
	
	for i in available_units.size():
		available_units[i].check_health()
		
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

	# CPU Check Attack Range
	for n in CPU_units.size():
		var cpu_pos = get_node("../TileMap").local_to_map(get_node("../BattleManager").CPU_units[n].position)

		var current_unit = get_node("../BattleManager").CPU_units[n]
		var unit_type = get_node("../BattleManager").CPU_units[n].unit_type
		#get_node("../BattleManager").available_units[i].position = hovertile.position							
	
		if unit_type == "Ranged" and CPU_units[n].unit_status == "Active":	
			get_node("../TileMap").get_child(1).stream = get_node("../TileMap").map_sfx[1]
			get_node("../TileMap").get_child(1).play()																		
			for j in 15:	
				get_node("../TileMap").set_cell(1, cpu_pos, -1, Vector2i(0, 0), 0)
				if hoverflag_1 == true and structure_flag1_ranged == true:
					get_node("../TileMap").set_cell(1, Vector2i(cpu_pos.x-j, cpu_pos.y), 48, Vector2i(0, 0), 0)
					#await get_tree().create_timer(0).timeout
					for h in node2D.structures.size():
						var set_cell = Vector2i(cpu_pos.x-j, cpu_pos.y)
						var structure_pos = get_node("../TileMap").local_to_map(node2D.structures[h].position)
						print(set_cell, structure_pos)
						if set_cell == structure_pos:
							structure_flag1_ranged = false
					for m in USER_units.size():
						
						if CPU_units[n].scale.x == 1 and CPU_units[n].position.x > USER_units[m].position.x:
							CPU_units[n].scale.x = 1
							#print("1")
						elif CPU_units[n].scale.x == -1 and CPU_units[n].position.x < USER_units[m].position.x:
							CPU_units[n].scale.x = -1
							#print("2")	
						if CPU_units[n].scale.x == -1 and CPU_units[n].position.x > USER_units[m].position.x:
							CPU_units[n].scale.x = 1
							#print("3")
						elif CPU_units[n].scale.x == 1 and CPU_units[n].position.x < USER_units[m].position.x:
							CPU_units[n].scale.x = -1
							#print("4")
														
						var user_pos = get_node("../TileMap").local_to_map(USER_units[m].position)	
						if get_node("../TileMap").get_cell_source_id(1, user_pos) == 48 and CPU_units[n].attacked == false:
							get_node("../BattleManager").CPU_units[n].get_child(0).play("attack")	
							await get_tree().create_timer(0.7).timeout
							get_node("../BattleManager").CPU_units[n].get_child(0).play("default")			
							await setLinePointsToBezierCurve(line_2d, CPU_units[n].get_node("Emitter").global_position, Vector2(0,0), Vector2(0,0), get_node("../BattleManager").USER_units[m].get_node("Emitter").global_position)							
							var _bumpedvector = get_node("../TileMap").local_to_map(USER_units[m].position)
							var _newvector = Vector2i(_bumpedvector.x-1, _bumpedvector.y)
							var _finalvector = get_node("../TileMap").map_to_local(_newvector) + Vector2(0,0) / 2
							
							get_node("../BattleManager").USER_units[m].position = _finalvector
							var tween: Tween = create_tween()
							tween.tween_property(get_node("../BattleManager").USER_units[m], "modulate:v", 1, 0.50).from(5)							
							
							get_node("../BattleManager").USER_units[m].unit_min -= CPU_units[n].unit_level
							CPU_units[n].xp += 1
							get_node("../BattleManager").USER_units[m].progressbar.set_value(get_node("../BattleManager").USER_units[m].unit_min)							
							
							hoverflag_1 = false
							CPU_units[n].attacked = true
							get_node("../BattleManager").check_health_now()
							await get_tree().create_timer(0.5).timeout
														
			await get_tree().create_timer(0.1).timeout	
			hoverflag_1 = true
			structure_flag1_ranged = true													
			for j in 15:	
				get_node("../TileMap").set_cell(1, cpu_pos, -1, Vector2i(0, 0), 0)
				if hoverflag_2 == true and structure_flag2_ranged == true:
					get_node("../TileMap").set_cell(1, Vector2i(cpu_pos.x, cpu_pos.y+j), 48, Vector2i(0, 0), 0)
					#await get_tree().create_timer(0).timeout
					for h in node2D.structures.size():
						var set_cell = Vector2i(cpu_pos.x, cpu_pos.y+j)
						var structure_pos = get_node("../TileMap").local_to_map(node2D.structures[h].position)
						print(set_cell, structure_pos)
						if set_cell == structure_pos:
							structure_flag2_ranged = false
					for m in USER_units.size():
						var user_pos = get_node("../TileMap").local_to_map(USER_units[m].position)	
						if get_node("../TileMap").get_cell_source_id(1, user_pos) == 48 and CPU_units[n].attacked == false:
							get_node("../BattleManager").CPU_units[n].get_child(0).play("attack")	
							await get_tree().create_timer(0.7).timeout
							get_node("../BattleManager").CPU_units[n].get_child(0).play("default")			
							await setLinePointsToBezierCurve(line_2d, CPU_units[n].get_node("Emitter").global_position, Vector2(0,0), Vector2(0,0), get_node("../BattleManager").USER_units[m].get_node("Emitter").global_position)							

							var _bumpedvector = get_node("../TileMap").local_to_map(USER_units[m].position)
							var _newvector = Vector2i(_bumpedvector.x, _bumpedvector.y+1)
							var _finalvector = get_node("../TileMap").map_to_local(_newvector) + Vector2(0,0) / 2
							
							get_node("../BattleManager").USER_units[m].position = _finalvector
							var tween: Tween = create_tween()
							tween.tween_property(get_node("../BattleManager").USER_units[m], "modulate:v", 1, 0.50).from(5)							

							get_node("../BattleManager").USER_units[m].unit_min -= CPU_units[n].unit_level
							CPU_units[n].xp += 1
							get_node("../BattleManager").USER_units[m].progressbar.set_value(get_node("../BattleManager").USER_units[m].unit_min)							
							
							hoverflag_2 = false
							CPU_units[n].attacked = true
							get_node("../BattleManager").check_health_now()
							await get_tree().create_timer(0.5).timeout
							
			await get_tree().create_timer(0.1).timeout
			hoverflag_2 = true	
			structure_flag2_ranged = true											
			for j in 15:	
				get_node("../TileMap").set_cell(1, cpu_pos, -1, Vector2i(0, 0), 0)
				if hoverflag_3 == true and structure_flag3_ranged == true:
					get_node("../TileMap").set_cell(1, Vector2i(cpu_pos.x+j, cpu_pos.y), 48, Vector2i(0, 0), 0)
					#await get_tree().create_timer(0).timeout
					for h in node2D.structures.size():
						var set_cell = Vector2i(cpu_pos.x+j, cpu_pos.y)
						var structure_pos = get_node("../TileMap").local_to_map(node2D.structures[h].position)
						print(set_cell, structure_pos)
						if set_cell == structure_pos:
							structure_flag3_ranged = false
					for m in USER_units.size():
						var user_pos = get_node("../TileMap").local_to_map(USER_units[m].position)	
						if get_node("../TileMap").get_cell_source_id(1, user_pos) == 48 and CPU_units[n].attacked == false:
							get_node("../BattleManager").CPU_units[n].get_child(0).play("attack")	
							await get_tree().create_timer(0.7).timeout
							get_node("../BattleManager").CPU_units[n].get_child(0).play("default")			
							await setLinePointsToBezierCurve(line_2d, CPU_units[n].get_node("Emitter").global_position, Vector2(0,0), Vector2(0,0), get_node("../BattleManager").USER_units[m].get_node("Emitter").global_position)							
							
							var _bumpedvector = get_node("../TileMap").local_to_map(USER_units[m].position)
							var _newvector = Vector2i(_bumpedvector.x+1, _bumpedvector.y)
							var _finalvector = get_node("../TileMap").map_to_local(_newvector) + Vector2(0,0) / 2
							
							get_node("../BattleManager").USER_units[m].position = _finalvector
							var tween: Tween = create_tween()
							tween.tween_property(get_node("../BattleManager").USER_units[m], "modulate:v", 1, 0.50).from(5)							

							get_node("../BattleManager").USER_units[m].unit_min -= CPU_units[n].unit_level
							CPU_units[n].xp += 1
							get_node("../BattleManager").USER_units[m].progressbar.set_value(get_node("../BattleManager").USER_units[m].unit_min)							
							
							hoverflag_3 = false
							CPU_units[n].attacked = true
							get_node("../BattleManager").check_health_now()
							await get_tree().create_timer(0.5).timeout
							
			await get_tree().create_timer(0.1).timeout
			hoverflag_3 = true	
			structure_flag3_ranged = true													
			for j in 15:	
				get_node("../TileMap").set_cell(1, cpu_pos, -1, Vector2i(0, 0), 0)
				if hoverflag_4 == true and structure_flag4_ranged == true:
					get_node("../TileMap").set_cell(1, Vector2i(cpu_pos.x, cpu_pos.y-j), 48, Vector2i(0, 0), 0)
					#await get_tree().create_timer(0).timeout
					for h in node2D.structures.size():
						var set_cell = Vector2i(cpu_pos.x, cpu_pos.y-j)
						var structure_pos = get_node("../TileMap").local_to_map(node2D.structures[h].position)
						print(set_cell, structure_pos)
						if set_cell == structure_pos:
							structure_flag4_ranged = false
					for m in USER_units.size():
						var user_pos = get_node("../TileMap").local_to_map(USER_units[m].position)	
						if get_node("../TileMap").get_cell_source_id(1, user_pos) == 48 and CPU_units[n].attacked == false:
							get_node("../BattleManager").CPU_units[n].get_child(0).play("attack")	
							await get_tree().create_timer(0.7).timeout
							get_node("../BattleManager").CPU_units[n].get_child(0).play("default")			
							await setLinePointsToBezierCurve(line_2d, CPU_units[n].get_node("Emitter").global_position, Vector2(0,0), Vector2(0,0), get_node("../BattleManager").USER_units[m].get_node("Emitter").global_position)							

							var _bumpedvector = get_node("../TileMap").local_to_map(USER_units[m].position)
							var _newvector = Vector2i(_bumpedvector.x, _bumpedvector.y-1)
							var _finalvector = get_node("../TileMap").map_to_local(_newvector) + Vector2(0,0) / 2
							
							get_node("../BattleManager").USER_units[m].position = _finalvector
							var tween: Tween = create_tween()
							tween.tween_property(get_node("../BattleManager").USER_units[m], "modulate:v", 1, 0.50).from(5)							

							get_node("../BattleManager").USER_units[m].unit_min -= CPU_units[n].unit_level
							CPU_units[n].xp += 1
							get_node("../BattleManager").USER_units[m].progressbar.set_value(get_node("../BattleManager").USER_units[m].unit_min)							
							
							hoverflag_4 = false
							CPU_units[n].attacked = true
							get_node("../BattleManager").check_health_now()
							await get_tree().create_timer(0.5).timeout
									
			hoverflag_4 = true							 						
			structure_flag4_ranged = true
				
		await get_tree().create_timer(1).timeout
		
		#Erase hover tiles
		for j in 16:
			for k in 16:
				get_node("../TileMap").set_cell(1, Vector2i(j,k), -1, Vector2i(0, 0), 0)

		if get_node("../BattleManager").CPU_units[n].attacked == false and CPU_units[n].unit_status == "Active":
			# CPU Movement range				
			var unit_target_pos = get_node("../TileMap").local_to_map(get_node("../BattleManager").CPU_units[n].position)
			var surrounding_cells = get_node("../TileMap").get_surrounding_cells(unit_target_pos)
		
			var random_cell = rng.randi_range(0, 3)				
			if get_node("../BattleManager").CPU_units[n].unit_movement == 1:
				for k in surrounding_cells.size(): 
					get_node("../TileMap").set_cell(1, Vector2i(surrounding_cells[k].x, surrounding_cells[k].y), 18, Vector2i(0, 0), 0)
					if surrounding_cells[k].x <= -1 or surrounding_cells[k].y >= 16 or surrounding_cells[k].x >= 16 or surrounding_cells[k].y <= -1:
						get_node("../TileMap").set_cell(1, Vector2i(surrounding_cells[k].x, surrounding_cells[k].y), -1, Vector2i(0, 0), 0)											
						get_node("../TileMap").get_child(1).stream = get_node("../TileMap").map_sfx[1]
						get_node("../TileMap").get_child(1).play()		
			
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
					get_node("../TileMap").get_child(1).stream = get_node("../TileMap").map_sfx[1]
					get_node("../TileMap").get_child(1).play()
			
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
					get_node("../TileMap").get_child(1).stream = get_node("../TileMap").map_sfx[1]
					get_node("../TileMap").get_child(1).play()
			
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
					get_node("../TileMap").get_child(1).stream = get_node("../TileMap").map_sfx[1]
					get_node("../TileMap").get_child(1).play()	
				
				get_node("../TileMap").set_cell(1, Vector2i(unit_target_pos.x+2, unit_target_pos.y+2), 18, Vector2i(0, 0), 0)																																								
				get_node("../TileMap").set_cell(1, Vector2i(unit_target_pos.x-2, unit_target_pos.y-2), 18, Vector2i(0, 0), 0)															
				get_node("../TileMap").set_cell(1, Vector2i(unit_target_pos.x+2, unit_target_pos.y-2), 18, Vector2i(0, 0), 0)																																								
				get_node("../TileMap").set_cell(1, Vector2i(unit_target_pos.x-2, unit_target_pos.y+2), 18, Vector2i(0, 0), 0)
			
			for m in USER_units.size():
				var user_pos = get_node("../TileMap").local_to_map(USER_units[m].position)
				if get_node("../TileMap").get_cell_source_id(1, user_pos) == 18:
					var surrounding_cells_array = get_node("../TileMap").get_surrounding_cells(user_pos)
					var target_random_cell = rng.randi_range(0, 3)
					# Find Path
					var patharray = get_node("../TileMap").astar_grid.get_point_path(unit_target_pos, surrounding_cells_array[target_random_cell])

					#Erase hover tiles
					for j in 16:
						for k in 16:
							get_node("../TileMap").set_cell(1, Vector2i(j,k), -1, Vector2i(0, 0), 0)
					
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
			
			get_node("../BattleManager").CPU_units[n].get_child(0).play("default")	
			
			await get_tree().create_timer(1).timeout
			get_node("../BattleManager").CPU_units[n].moved = true
				
			#Erase hover tiles
			for j in 16:
				for k in 16:
					get_node("../TileMap").set_cell(1, Vector2i(j,k), -1, Vector2i(0, 0), 0)		

			get_node("../TileMap").hovertile.show()
			get_node("../TileMap").moving = false
			get_node("../BattleManager").CPU_units[n].get_child(0).play("default")
			get_node("../Control").only_once = true	

			# Attacks
			for j in USER_units.size():
				var user_target_pos = get_node("../TileMap").local_to_map(get_node("../BattleManager").USER_units[j].position)
				var user_surrounding_cells = get_node("../TileMap").get_surrounding_cells(user_target_pos)			
				for i in 4:
					if get_node("../TileMap").local_to_map(CPU_units[n].position) == user_surrounding_cells[i]:
						var attack_center_pos = get_node("../TileMap").map_to_local(get_node("../TileMap").local_to_map(get_node("../BattleManager").USER_units[j].position)) + Vector2(0,0) / 2	
						
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
							#print("4"z)																																				
																																	
						
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
									
						var _bumpedvector = get_node("../TileMap").local_to_map(get_node("../BattleManager").USER_units[j].position)
						
						get_node("../Camera2D").shake(0.5, 30, 3)
						
						get_node("../TileMap").get_child(1).stream = get_node("../TileMap").map_sfx[3]
						get_node("../TileMap").get_child(1).play()

						if i == 0:
							var tile_center_pos = get_node("../TileMap").map_to_local(Vector2i(_bumpedvector.x-1, _bumpedvector.y)) + Vector2(0,0) / 2
							USER_units[j].position = tile_center_pos
							var unit_pos = get_node("../TileMap").local_to_map(USER_units[j].position)
							USER_units[j].position = tile_center_pos											
							USER_units[j].z_index = unit_pos.x + unit_pos.y
							var tween: Tween = create_tween()
							tween.tween_property(USER_units[j], "modulate:v", 1, 0.50).from(5)
							get_node("../BattleManager").CPU_units[n].xp += 1										
							get_node("../BattleManager").USER_units[j].unit_min -= get_node("../BattleManager").CPU_units[n].unit_level
							get_node("../BattleManager").USER_units[j].progressbar.set_value(get_node("../BattleManager").USER_units[j].unit_min)
							#print("A")
							print('CPU moved')
							check_health_now()
							await get_tree().create_timer(1).timeout
							get_node("../BattleManager").CPU_units[n].attacked = true
							get_node("../BattleManager").check_health_now()
							break
						
						if i == 1:
							var tile_center_pos = get_node("../TileMap").map_to_local(Vector2i(_bumpedvector.x, _bumpedvector.y-1)) + Vector2(0,0) / 2
							USER_units[j].position = tile_center_pos
							var unit_pos = get_node("../TileMap").local_to_map(USER_units[j].position)
							USER_units[j].position = tile_center_pos											
							USER_units[j].z_index = unit_pos.x + unit_pos.y
							var tween: Tween = create_tween()
							tween.tween_property(USER_units[j], "modulate:v", 1, 0.50).from(5)
							get_node("../BattleManager").CPU_units[n].xp += 1										
							get_node("../BattleManager").USER_units[j].unit_min -= get_node("../BattleManager").CPU_units[n].unit_level
							get_node("../BattleManager").USER_units[j].progressbar.set_value(get_node("../BattleManager").USER_units[j].unit_min)
							#print("A")
							print('CPU moved')
							check_health_now()
							await get_tree().create_timer(1).timeout
							get_node("../BattleManager").CPU_units[n].attacked = true
							get_node("../BattleManager").check_health_now()
							break
						
						if i == 2:
							var tile_center_pos = get_node("../TileMap").map_to_local(Vector2i(_bumpedvector.x+1, _bumpedvector.y)) + Vector2(0,0) / 2
							USER_units[j].position = tile_center_pos
							var unit_pos = get_node("../TileMap").local_to_map(USER_units[j].position)
							USER_units[j].position = tile_center_pos											
							USER_units[j].z_index = unit_pos.x + unit_pos.y
							var tween: Tween = create_tween()
							tween.tween_property(USER_units[j], "modulate:v", 1, 0.50).from(5)
							get_node("../BattleManager").CPU_units[n].xp += 1										
							get_node("../BattleManager").USER_units[j].unit_min -= get_node("../BattleManager").CPU_units[n].unit_level
							get_node("../BattleManager").USER_units[j].progressbar.set_value(get_node("../BattleManager").USER_units[j].unit_min)
							#print("A")
							print('CPU moved')
							check_health_now()
							await get_tree().create_timer(1).timeout
							get_node("../BattleManager").CPU_units[n].attacked = true
							get_node("../BattleManager").check_health_now()
							break
						
						if i == 3:
							var tile_center_pos = get_node("../TileMap").map_to_local(Vector2i(_bumpedvector.x, _bumpedvector.y+1)) + Vector2(0,0) / 2
							USER_units[j].position = tile_center_pos
							var unit_pos = get_node("../TileMap").local_to_map(USER_units[j].position)
							USER_units[j].position = tile_center_pos											
							USER_units[j].z_index = unit_pos.x + unit_pos.y
							var tween: Tween = create_tween()
							tween.tween_property(USER_units[j], "modulate:v", 1, 0.50).from(5)
							get_node("../BattleManager").CPU_units[n].xp += 1										
							get_node("../BattleManager").USER_units[j].unit_min -= get_node("../BattleManager").CPU_units[n].unit_level
							get_node("../BattleManager").USER_units[j].progressbar.set_value(get_node("../BattleManager").USER_units[j].unit_min)
							#print("A")
							print('CPU moved')	
							check_health_now()
							await get_tree().create_timer(1).timeout
							get_node("../BattleManager").CPU_units[n].attacked = true
							get_node("../BattleManager").check_health_now()
							break							
																													
						return	 	
					
					get_node("../BattleManager").check_health_now()
			
	for k in get_node("../BattleManager").available_units.size():
		get_node("../BattleManager").available_units[k].moved = false
		get_node("../BattleManager").available_units[k].attacked = false
		get_node("../TileMap").moves_counter = 0

	get_node("../BattleManager").check_health_now()

	get_node("../Control").get_child(19).text = "USER TURN"
	get_node("../Hover_tile").show()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			
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
			available_units[i].unit_status = "Active"
			available_units[i].unit_type = "Ranged"	
			available_units[i].unit_movement = 4
		else:
			available_units[i].unit_team = 2
			available_units[i].unit_status = "Active"		
			available_units[i].unit_type = "Ranged"	
			available_units[i].unit_movement = 4		
	
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

func check_health_now():
	for z in available_units.size():
		available_units[z].check_health()		

func setLinePointsToBezierCurve(line: Line2D, a: Vector2, postA: Vector2, preB: Vector2, b: Vector2):
	line.set_joint_mode(2)
	var curve := Curve2D.new()
	curve.add_point(a, Vector2.ZERO, postA)
	curve.add_point(b, preB, Vector2.ZERO)
	line.points = curve.get_baked_points()	
	
	get_node("../TileMap").sprite_2d.show()
	get_node("../TileMap").sprite_2d.position = line.points[0] 
	for i in line.points.size():
		await get_tree().create_timer(0).timeout
		get_node("../TileMap").sprite_2d.position = line.points[i]				
											
	get_node("../TileMap").get_child(1).stream = get_node("../TileMap").map_sfx[4]
	get_node("../TileMap").get_child(1).play()	
	
	get_node("../TileMap").sprite_2d.hide()
	var explosion = preload("res://prefab/vfx/explosion_area_2d.tscn")
	var explosion_instance = explosion.instantiate()
	var explosion_pos = get_node("../TileMap").map_to_local(get_node("../TileMap").sprite_2d.position) + Vector2(0,0) / 2
	
	var tile_pos = get_node("../TileMap").local_to_map(get_node("../TileMap").sprite_2d.position)		
	explosion_instance.set_name("explosion")
	get_parent().add_child(explosion_instance)
	explosion_instance.position = get_node("../TileMap").sprite_2d.position	
	explosion_instance.z_index = (tile_pos.x + tile_pos.y) + 100
	get_node("../Camera2D").shake(1, 30, 3)			
