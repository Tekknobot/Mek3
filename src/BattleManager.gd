extends Node2D

var rng = RandomNumberGenerator.new()
var _int = [0, 1, 2, 3, 4, 5, 6 ,7, 8, 9]
var _int_full = []
var available_units = []

var random_unit = 0
var random_user = 0

var team_1 = []
var team_2 = []

var team_1_group
var team_2_group

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

# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("../TurnManager").user_turn_started.connect(on_user_turn_started)
	get_node("../TurnManager").cpu_turn_started.connect(on_cpu_turn_started)
	get_node("../TurnStack").turn_over.connect(on_turn_over)
	get_node("../TurnManager").start()
				
	available_units = get_tree().get_nodes_in_group("mek_scenes")

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
	
	team_arrays()
	
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	available_units = get_tree().get_nodes_in_group("mek_scenes")	
	
	team_1_group = get_tree().get_nodes_in_group("Team 1: Inactive")
	if team_1_group.size() == 5:
		await get_tree().create_timer(2).timeout
		print("CPU WINS!")
		get_tree().reload_current_scene();
		
	team_2_group = get_tree().get_nodes_in_group("Team 2: Inactive")
	if team_2_group.size() == 5:
		await get_tree().create_timer(2).timeout
		get_tree().reload_current_scene()	
		print("USER WINS!")

func _input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_SPACE:
			on_turn_over()

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
	#Remove hover tiles										
	for j in 16:
		for k in 16:
			get_node("../TileMap").set_cell(1, Vector2i(j,k), -1, Vector2i(0, 0), 0)		
	
	print('CPU turn')
	get_node("../TileMap").moving = true	
	
	# Pick Mek
	available_units = get_tree().get_nodes_in_group("mek_scenes")
	
	random_unit = rng.randi_range(0, team_1.size()-1)
	random_user = rng.randi_range(0, team_2.size()-1)	
	
	print("ATTACK ", team_1[random_unit].unit_name, " Team ", team_1[random_unit].unit_team, " Unit. " ,team_1[random_unit].unit_num)
	print("BY " , team_2[random_user].unit_name, " Team ", team_2[random_user].unit_team, " Unit. " ,team_2[random_user].unit_num)
	
	if get_node("../BattleManager").team_1[random_unit].unit_status == "Inactive":
		print("Try UNIT again.")
		on_cpu_turn_started()
		return	
	if get_node("../BattleManager").team_2[random_user].unit_status == "Inactive":
		print("Try USER again.")
		on_cpu_turn_started()
		return
				
	var cpu_tile_pos = get_node("../TileMap").local_to_map(get_node("../BattleManager").team_2[random_user].position)
	var user_tile_pos = get_node("../TileMap").local_to_map(get_node("../BattleManager").team_1[random_unit].position)
	var surrounding_cells = get_node("../TileMap").get_surrounding_cells(user_tile_pos)
	var random_cell = rng.randi_range(0, 3)
	# Find Path
	var patharray = get_node("../TileMap").astar_grid.get_point_path(cpu_tile_pos, surrounding_cells[random_cell])
	
	# Set hover cells
	for h in patharray.size():
		await get_tree().create_timer(0.01).timeout
		get_node("../TileMap").set_cell(1, patharray[h], 18, Vector2i(0, 0), 0)	
	
	get_node("../TileMap").hovertile.hide()
	get_node("../BattleManager").team_2[random_user].get_child(0).play("move")

	# Move unit		
	for h in patharray.size():
		var tile_center_pos = get_node("../TileMap").map_to_local(patharray[h]) + Vector2(0,0) / 2
		var tween = create_tween()
		var random_unit_pos = get_node("../TileMap").local_to_map(get_node("../BattleManager").team_2[random_user].position)
		get_node("../BattleManager").team_2[random_user].z_index = random_unit_pos.x + random_unit_pos.y		
		tween.tween_property(get_node("../BattleManager").team_2[random_user], "position", tile_center_pos, 0.35)				
		get_node("../TileMap").get_child(1).stream = get_node("../TileMap").map_sfx[2]
		get_node("../TileMap").get_child(1).play()	
		await get_tree().create_timer(0.35).timeout
	
	for j in 16:
		for k in 16:
			get_node("../TileMap").set_cell(1, Vector2i(j,k), -1, Vector2i(0, 0), 0)	
	
	get_node("../TileMap").hovertile.show()
	get_node("../TileMap").moving = false
	get_node("../BattleManager").team_2[random_user].get_child(0).play("default")
	get_node("../Control").only_once = true	

	# Attacks
	for j in get_node("../BattleManager").team_1.size():
		for i in 4:
			if get_node("../TileMap").local_to_map(get_node("../BattleManager").team_2[random_user].position) == surrounding_cells[i]:
				var attack_center_pos = get_node("../TileMap").map_to_local(get_node("../TileMap").local_to_map(get_node("../BattleManager").team_1[random_unit].position)) + Vector2(0,0) / 2	
				
				if team_2[random_user].scale.x == 1 and team_2[random_user].position.x > attack_center_pos.x:
					team_2[random_user].scale.x = 1
					#print("1")
				elif team_2[random_user].scale.x == -1 and team_2[random_user].position.x < attack_center_pos.x:
					team_2[random_user].scale.x = -1
					#print("2")	
				if team_2[random_user].scale.x == -1 and team_2[random_user].position.x > attack_center_pos.x:
					team_2[random_user].scale.x = 1
					#print("3")
				elif team_2[random_user].scale.x == 1 and team_2[random_user].position.x < attack_center_pos.x:
					team_2[random_user].scale.x = -1
					#print("4")																																				
																															
				
				get_node("../BattleManager").team_2[random_user].get_child(0).play("attack")
				
				var sfx
				
				if get_node("../BattleManager").team_2[random_user].unit_name == "Panther":
					sfx = 5
				else:
					sfx = 4
					
				get_node("../TileMap").get_child(1).stream = get_node("../TileMap").map_sfx[sfx]
				get_node("../TileMap").get_child(1).play()		
								
				await get_tree().create_timer(0.5).timeout
				get_node("../BattleManager").team_2[random_user].get_child(0).play("default")
							
				var _bumpedvector = get_node("../TileMap").local_to_map(get_node("../BattleManager").team_1[random_unit].position)
				
				get_node("../Camera2D").shake(0.5, 30, 3)
				
				get_node("../TileMap").get_child(1).stream = get_node("../TileMap").map_sfx[3]
				get_node("../TileMap").get_child(1).play()	
				
				if i == 0:
					var tile_center_pos = get_node("../TileMap").map_to_local(Vector2i(_bumpedvector.x-1, _bumpedvector.y)) + Vector2(0,0) / 2
					#for k in team_1.size():
					if surrounding_cells[i] == surrounding_cells[random_cell]:
						get_node("../BattleManager").team_1[random_unit].position = tile_center_pos
						var unit_pos = get_node("../TileMap").local_to_map(team_1[random_unit].position)
						team_1[random_unit].position = tile_center_pos											
						team_1[random_unit].z_index = unit_pos.x + unit_pos.y
						var tween: Tween = create_tween()
						tween.tween_property(team_1[random_unit], "modulate:v", 1, 0.50).from(5)
						get_node("../BattleManager").team_2[random_user].xp += 1										
						get_node("../BattleManager").team_1[random_unit].unit_min -= get_node("../BattleManager").team_2[random_user].unit_level
						get_node("../BattleManager").team_1[random_unit].progressbar.set_value(get_node("../BattleManager").team_1[random_unit].unit_min)
						#print("A")
						print('CPU moved')
						on_turn_over()
						return
				
				if i == 1:
					var tile_center_pos = get_node("../TileMap").map_to_local(Vector2i(_bumpedvector.x, _bumpedvector.y-1)) + Vector2(0,0) / 2
					#for k in team_1.size():
					if surrounding_cells[i] == surrounding_cells[random_cell]:
						get_node("../BattleManager").team_1[random_unit].position = tile_center_pos								
						var unit_pos = get_node("../TileMap").local_to_map(team_1[random_unit].position)
						team_1[random_unit].position = tile_center_pos											
						team_1[random_unit].z_index = unit_pos.x + unit_pos.y
						var tween: Tween = create_tween()
						tween.tween_property(team_1[random_unit], "modulate:v", 1, 0.50).from(5)						
						get_node("../BattleManager").team_2[random_user].xp += 1										
						get_node("../BattleManager").team_1[random_unit].unit_min -= get_node("../BattleManager").team_2[random_user].unit_level
						get_node("../BattleManager").team_1[random_unit].progressbar.set_value(get_node("../BattleManager").team_1[random_unit].unit_min)							
						#print("B")
						print('CPU moved')
						on_turn_over()
						return
				
				if i == 2:
					var tile_center_pos = get_node("../TileMap").map_to_local(Vector2i(_bumpedvector.x+1, _bumpedvector.y)) + Vector2(0,0) / 2
					#for k in team_1.size():
					if surrounding_cells[i] == surrounding_cells[random_cell]:
						get_node("../BattleManager").team_1[random_unit].position = tile_center_pos								
						var unit_pos = get_node("../TileMap").local_to_map(team_1[random_unit].position)
						team_1[random_unit].position = tile_center_pos											
						team_1[random_unit].z_index = unit_pos.x + unit_pos.y
						var tween: Tween = create_tween()
						tween.tween_property(team_1[random_unit], "modulate:v", 1, 0.50).from(5)
						get_node("../BattleManager").team_2[random_user].xp += 1										
						get_node("../BattleManager").team_1[random_unit].unit_min -= get_node("../BattleManager").team_2[random_user].unit_level
						get_node("../BattleManager").team_1[random_unit].progressbar.set_value(get_node("../BattleManager").team_1[random_unit].unit_min)
						#print("C")
						print('CPU moved')
						on_turn_over()
						return
				
				if i == 3:
					var tile_center_pos = get_node("../TileMap").map_to_local(Vector2i(_bumpedvector.x, _bumpedvector.y+1)) + Vector2(0,0) / 2
					#for k in team_1.size():
					if surrounding_cells[i] == surrounding_cells[random_cell]:
						get_node("../BattleManager").team_1[random_unit].position = tile_center_pos								
						var unit_pos = get_node("../TileMap").local_to_map(team_1[random_unit].position)
						team_1[random_unit].position = tile_center_pos											
						team_1[random_unit].z_index = unit_pos.x + unit_pos.y	
						var tween: Tween = create_tween()
						tween.tween_property(team_1[random_unit], "modulate:v", 1, 0.50).from(5)
						get_node("../BattleManager").team_2[random_user].xp += 1										
						get_node("../BattleManager").team_1[random_unit].unit_min -= get_node("../BattleManager").team_2[random_user].unit_level
						get_node("../BattleManager").team_1[random_unit].progressbar.set_value(get_node("../BattleManager").team_1[random_unit].unit_min)
						#print("D")
						print('CPU moved')
						on_turn_over()
						return
				return																		
			
func on_turn_over() -> void:
	get_node("../TurnManager").advance_turn()
	
func get_random():
	_int = _int_full.duplicate()
	_int.shuffle()
	var random_int = _int.pop_front()
	return random_int	
	
func team_arrays():
	
	for i in available_units.size():
		if available_units[i].unit_team == 1:
			team_1.append(available_units[i])
					
	for i in available_units.size():		
		if available_units[i].unit_team == 2:
			team_2.append(available_units[i])

	for i in team_1.size():	
		team_1[i].unit_num = i
		print(team_1[i].unit_name, " Team " , team_1[i].unit_team, " Unit. ", team_1[i].unit_num)
			
	for i in team_2.size():	
		team_2[i].unit_num = i
		print(team_2[i].unit_name, " Team " , team_2[i].unit_team, " Unit. ", team_2[i].unit_num)

	# Team 1 color
	for i in team_1.size():
		if get_node("../BattleManager").team_1[i].unit_team == 1:
			#get_node("../BattleManager").team_1[i].get_child(0).modulate = Color8(255, 255, 0)
			pass
			
	# Team 2 color
	for i in team_2.size():
		if get_node("../BattleManager").team_2[i].unit_team == 2:
			get_node("../BattleManager").team_2[i].get_child(0).modulate = Color8(255, 110, 255)
			get_node("../BattleManager").team_2[i].unit_level = 2
			get_node("../BattleManager").team_2[i].unit_attack = 2
			get_node("../BattleManager").team_2[i].unit_defence = 2
			
			
	arrays_set = true
