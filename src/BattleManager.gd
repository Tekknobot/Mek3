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
@export var spawn_button: Button
@export var spawnagain_button: Button
@export var turn_button: Button
@export var ai_button: Button
@export var score: Button
@export var picker: HBoxContainer


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

var Z1 = preload("res://scenes/mek/Z1.scn")

var mek_array = [M1, M2, M3, R1, R2, R3, R4, S1, S2, S3]

var M1_thumb_bw = preload("res://assets/portraits/bw/m1.png")
var M2_thumb_bw = preload("res://assets/portraits/bw/m2.png")
var M3_thumb_bw = preload("res://assets/portraits/bw/m3.png")
var R1_thumb_bw = preload("res://assets/portraits/bw/r1.png")
var R2_thumb_bw = preload("res://assets/portraits/bw/r2.png")
var R3_thumb_bw = preload("res://assets/portraits/bw/r3.png")
var R4_thumb_bw = preload("res://assets/portraits/bw/r4.png")
var S1_thumb_bw = preload("res://assets/portraits/bw/s1.png")
var S2_thumb_bw = preload("res://assets/portraits/bw/s2.png")
var S3_thumb_bw = preload("res://assets/portraits/bw/s3.png")

var M1_thumb_norm = preload("res://assets/portraits/mek_portraits/m1.png")
var M2_thumb_norm = preload("res://assets/portraits/mek_portraits/m2.png")
var M3_thumb_norm = preload("res://assets/portraits/mek_portraits/m3.png")
var R1_thumb_norm = preload("res://assets/portraits/mek_portraits/r1.png")
var R2_thumb_norm = preload("res://assets/portraits/mek_portraits/r2.png")
var R3_thumb_norm = preload("res://assets/portraits/mek_portraits/r3.png")
var R4_thumb_norm = preload("res://assets/portraits/mek_portraits/r4.png")
var S1_thumb_norm = preload("res://assets/portraits/mek_portraits/s1.png")
var S2_thumb_norm = preload("res://assets/portraits/mek_portraits/s2.png")
var S3_thumb_norm = preload("res://assets/portraits/mek_portraits/s3.png")

var hoverflag_1 = true
var hoverflag_2 = true
var hoverflag_3 = true
var hoverflag_4 = true

var structure_flag1_ranged = true
var structure_flag2_ranged = true
var structure_flag3_ranged = true
var structure_flag4_ranged = true

var stored_cells = []
var team_two = []

@onready var line_2d = $"../Line2D"
@onready var post_a = $"../postA"
@onready var pre_b = $"../preB"
@onready var sprite_2d = $"../Sprite2D"

var spawning = false

var inactive_total_cpu = 0
var inactive_total_user = 0
var audio_flag = false

var cpu_turn = false
var user_turn = false

var cpu_pos
var user_pos

var user_within = false
var user_check = false

var cpu_within = false
var cpu_check = false

var open_tiles = []
var random = []

var user_keys = []
var user_dict = {}
var unit_tag_dict = {}

var meks_set = false

var teampick_count = 0

var ai_mode_bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("../TurnManager").user_turn_started.connect(on_user_turn_started)
	get_node("../TurnManager").cpu_turn_started.connect(on_cpu_turn_started)
	get_node("../TurnStack").turn_over.connect(on_turn_over)
	get_node("../TurnManager").start()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	inactive_total_cpu = get_tree().get_nodes_in_group("CPU Inactive")
	inactive_total_user = get_tree().get_nodes_in_group("USER Inactive")
	
	score.text = str(inactive_total_cpu.size()) + " - " + str(inactive_total_user.size())
		
	if meks_set == true:	
		if inactive_total_cpu.size() == 5 and audio_flag == false:
			spawnagain_button.show()

		if inactive_total_user.size() == 5 and audio_flag == false:
			get_node("../ALL_CLEAR").show()
			var tween: Tween = create_tween()
			tween.tween_property(get_node("../ALL_CLEAR"), "position", Vector2(200, -150), 1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
			get_node("../TileMap").get_child(1).stream = get_node("../TileMap").map_sfx[9]
			get_node("../TileMap").get_child(1).play()	
			get_node("../ALL_CLEAR").get_child(1).text = "CPU WINNER!"			
			print("YOU LOSE!")
			audio_flag = true
	
		
func _input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_SPACE:
			get_node("../TurnManager").cpu_turn_started.emit()
			
		if event.pressed and event.keycode == KEY_ESCAPE:
			#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			get_tree().change_scene_to_file("res://scenes/menu.tscn")
			
		if event.pressed and event.keycode == KEY_R:
			spawn()		

		if event.pressed and event.keycode == KEY_U:
			on_user_ai_started()		
							
func on_user_turn_started() -> void:
	print("USER turn")
	print('awaiting action')
	await get_node("../TileMap").unit_used_turn == true
	print('USER acted')
	await get_tree().create_timer(0.1).timeout
	get_node("../TurnManager").cpu_turn_started.emit()
	
func on_cpu_turn_started() -> void:		
	get_node("../Control").get_child(19).text = "CPU Moving..."
	get_node("../Control").get_child(18).hide() # moves count
	get_node("../TileMap").hovertile.hide()
	#Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	get_node("../TileMap").moving = true
	
	for i in get_node("../BattleManager").available_units.size():
		get_node("../BattleManager").available_units[i].moved = false
		get_node("../BattleManager").available_units[i].attacked = false
		get_node("../TileMap").moves_counter = 0
		
	get_node("../BattleManager").structure_flag1_ranged = true
	get_node("../BattleManager").structure_flag2_ranged = true
	get_node("../BattleManager").structure_flag3_ranged = true
	get_node("../BattleManager").structure_flag4_ranged = true
			
	available_units = get_tree().get_nodes_in_group("mek_scenes")	
	
	for i in available_units.size():
		available_units[i].check_health()
		
	#Remove hover tiles										
	for j in 16:
		for k in 16:
			get_node("../TileMap").set_cell(1, Vector2i(j,k), -1, Vector2i(0, 0), 0)		
	
	print('CPU turn')	
	
	for i in available_units.size():
		if available_units[i].unit_team == 2:
			available_units[i].add_to_group("CPU_Team")
		if available_units[i].unit_team == 1:
			available_units[i].add_to_group("USER_Team")
				
	CPU_units = get_tree().get_nodes_in_group("CPU_Team")
	USER_units = get_tree().get_nodes_in_group("USER_Team")	

	# CPU Check Attack Range
	for n in CPU_units.size():
		cpu_pos = get_node("../TileMap").local_to_map(get_node("../BattleManager").CPU_units[n].position)

		var current_unit = get_node("../BattleManager").CPU_units[n]
		var unit_type = get_node("../BattleManager").CPU_units[n].unit_type
		#get_node("../BattleManager").available_units[i].position = hovertile.position							
	
		if unit_type == "Ranged" and CPU_units[n].unit_status == "Active":	
			get_node("../TileMap").get_child(1).stream = get_node("../TileMap").map_sfx[1]
			get_node("../TileMap").get_child(1).play()																		
			for j in 16:	
				get_node("../TileMap").set_cell(1, cpu_pos, -1, Vector2i(0, 0), 0)
				if hoverflag_1 == true and structure_flag1_ranged == true:
					get_node("../TileMap").set_cell(1, Vector2i(cpu_pos.x-j, cpu_pos.y), 48, Vector2i(0, 0), 0)
					#await get_tree().create_timer(0).timeout
					for h in node2D.structures.size():
						var set_cell = Vector2i(cpu_pos.x-j, cpu_pos.y)
						var structure_pos = get_node("../TileMap").local_to_map(node2D.structures[h].position)
						#print(set_cell, structure_pos)
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
							await SetLinePoints(line_2d, CPU_units[n].get_node("Emitter").global_position, Vector2(0,0), Vector2(0,0), get_node("../BattleManager").USER_units[m].get_node("Emitter").global_position)							
							var _bumpedvector = get_node("../TileMap").local_to_map(USER_units[m].position)
							var _newvector = Vector2i(_bumpedvector.x-1, _bumpedvector.y)
							var _finalvector = get_node("../TileMap").map_to_local(_newvector) + Vector2(0,0) / 2
							
							get_node("../BattleManager").USER_units[m].position = _finalvector
							var tween: Tween = create_tween()
							tween.tween_property(get_node("../BattleManager").USER_units[m], "modulate:v", 1, 0.50).from(5)							
							
							get_node("../BattleManager").USER_units[m].unit_min -= CPU_units[n].unit_level - get_node("../BattleManager").USER_units[m].unit_defence
							CPU_units[n].xp += 1
							get_node("../BattleManager").USER_units[m].progressbar.set_value(get_node("../BattleManager").USER_units[m].unit_min)							
							
							hoverflag_1 = false
							CPU_units[n].attacked = true
							get_node("../BattleManager").check_health_now()
			
							await get_tree().create_timer(0.5).timeout
														
			await get_tree().create_timer(0.1).timeout	

			hoverflag_1 = true
			structure_flag1_ranged = true													
			for j in 16:	
				get_node("../TileMap").set_cell(1, cpu_pos, -1, Vector2i(0, 0), 0)
				if hoverflag_2 == true and structure_flag2_ranged == true:
					get_node("../TileMap").set_cell(1, Vector2i(cpu_pos.x, cpu_pos.y+j), 48, Vector2i(0, 0), 0)
					#await get_tree().create_timer(0).timeout
					for h in node2D.structures.size():
						var set_cell = Vector2i(cpu_pos.x, cpu_pos.y+j)
						var structure_pos = get_node("../TileMap").local_to_map(node2D.structures[h].position)
						#print(set_cell, structure_pos)
						if set_cell == structure_pos:
							structure_flag2_ranged = false
					for m in USER_units.size():
						var user_pos = get_node("../TileMap").local_to_map(USER_units[m].position)	
						if get_node("../TileMap").get_cell_source_id(1, user_pos) == 48 and CPU_units[n].attacked == false:
							get_node("../BattleManager").CPU_units[n].get_child(0).play("attack")	
							await get_tree().create_timer(0.7).timeout
							get_node("../BattleManager").CPU_units[n].get_child(0).play("default")			
							await SetLinePoints(line_2d, CPU_units[n].get_node("Emitter").global_position, Vector2(0,0), Vector2(0,0), get_node("../BattleManager").USER_units[m].get_node("Emitter").global_position)							

							var _bumpedvector = get_node("../TileMap").local_to_map(USER_units[m].position)
							var _newvector = Vector2i(_bumpedvector.x, _bumpedvector.y+1)
							var _finalvector = get_node("../TileMap").map_to_local(_newvector) + Vector2(0,0) / 2
							
							get_node("../BattleManager").USER_units[m].position = _finalvector
							var tween: Tween = create_tween()
							tween.tween_property(get_node("../BattleManager").USER_units[m], "modulate:v", 1, 0.50).from(5)							

							get_node("../BattleManager").USER_units[m].unit_min -= CPU_units[n].unit_level - get_node("../BattleManager").USER_units[m].unit_defence
							CPU_units[n].xp += 1
							get_node("../BattleManager").USER_units[m].progressbar.set_value(get_node("../BattleManager").USER_units[m].unit_min)							
							
							hoverflag_2 = false
							CPU_units[n].attacked = true
							get_node("../BattleManager").check_health_now()
							
							await get_tree().create_timer(0.5).timeout
							
			await get_tree().create_timer(0.1).timeout
			
			hoverflag_2 = true	
			structure_flag2_ranged = true											
			for j in 16:	
				get_node("../TileMap").set_cell(1, cpu_pos, -1, Vector2i(0, 0), 0)
				if hoverflag_3 == true and structure_flag3_ranged == true:
					get_node("../TileMap").set_cell(1, Vector2i(cpu_pos.x+j, cpu_pos.y), 48, Vector2i(0, 0), 0)
					#await get_tree().create_timer(0).timeout
					for h in node2D.structures.size():
						var set_cell = Vector2i(cpu_pos.x+j, cpu_pos.y)
						var structure_pos = get_node("../TileMap").local_to_map(node2D.structures[h].position)
						#print(set_cell, structure_pos)
						if set_cell == structure_pos:
							structure_flag3_ranged = false
					for m in USER_units.size():
						var user_pos = get_node("../TileMap").local_to_map(USER_units[m].position)	
						if get_node("../TileMap").get_cell_source_id(1, user_pos) == 48 and CPU_units[n].attacked == false:
							get_node("../BattleManager").CPU_units[n].get_child(0).play("attack")	
							await get_tree().create_timer(0.7).timeout
							get_node("../BattleManager").CPU_units[n].get_child(0).play("default")			
							await SetLinePoints(line_2d, CPU_units[n].get_node("Emitter").global_position, Vector2(0,0), Vector2(0,0), get_node("../BattleManager").USER_units[m].get_node("Emitter").global_position)							
							
							var _bumpedvector = get_node("../TileMap").local_to_map(USER_units[m].position)
							var _newvector = Vector2i(_bumpedvector.x+1, _bumpedvector.y)
							var _finalvector = get_node("../TileMap").map_to_local(_newvector) + Vector2(0,0) / 2
							
							get_node("../BattleManager").USER_units[m].position = _finalvector
							var tween: Tween = create_tween()
							tween.tween_property(get_node("../BattleManager").USER_units[m], "modulate:v", 1, 0.50).from(5)							

							get_node("../BattleManager").USER_units[m].unit_min -= CPU_units[n].unit_level - get_node("../BattleManager").USER_units[m].unit_defence
							CPU_units[n].xp += 1
							get_node("../BattleManager").USER_units[m].progressbar.set_value(get_node("../BattleManager").USER_units[m].unit_min)							
							
							hoverflag_3 = false
							CPU_units[n].attacked = true
							get_node("../BattleManager").check_health_now()
							
							await get_tree().create_timer(0.5).timeout
							
			await get_tree().create_timer(0.1).timeout
							
			hoverflag_3 = true	
			structure_flag3_ranged = true													
			for j in 16:	
				get_node("../TileMap").set_cell(1, cpu_pos, -1, Vector2i(0, 0), 0)
				if hoverflag_4 == true and structure_flag4_ranged == true:
					get_node("../TileMap").set_cell(1, Vector2i(cpu_pos.x, cpu_pos.y-j), 48, Vector2i(0, 0), 0)
					#await get_tree().create_timer(0).timeout
					for h in node2D.structures.size():
						var set_cell = Vector2i(cpu_pos.x, cpu_pos.y-j)
						var structure_pos = get_node("../TileMap").local_to_map(node2D.structures[h].position)
						#print(set_cell, structure_pos)
						if set_cell == structure_pos:
							structure_flag4_ranged = false
					for m in USER_units.size():
						var user_pos = get_node("../TileMap").local_to_map(USER_units[m].position)	
						if get_node("../TileMap").get_cell_source_id(1, user_pos) == 48 and CPU_units[n].attacked == false:
							get_node("../BattleManager").CPU_units[n].get_child(0).play("attack")	
							await get_tree().create_timer(0.7).timeout
							get_node("../BattleManager").CPU_units[n].get_child(0).play("default")			
							await SetLinePoints(line_2d, CPU_units[n].get_node("Emitter").global_position, Vector2(0,0), Vector2(0,0), get_node("../BattleManager").USER_units[m].get_node("Emitter").global_position)							

							var _bumpedvector = get_node("../TileMap").local_to_map(USER_units[m].position)
							var _newvector = Vector2i(_bumpedvector.x, _bumpedvector.y-1)
							var _finalvector = get_node("../TileMap").map_to_local(_newvector) + Vector2(0,0) / 2
							
							get_node("../BattleManager").USER_units[m].position = _finalvector
							var tween: Tween = create_tween()
							tween.tween_property(get_node("../BattleManager").USER_units[m], "modulate:v", 1, 0.50).from(5)							

							get_node("../BattleManager").USER_units[m].unit_min -= CPU_units[n].unit_level - get_node("../BattleManager").USER_units[m].unit_defence
							CPU_units[n].xp += 1
							get_node("../BattleManager").USER_units[m].progressbar.set_value(get_node("../BattleManager").USER_units[m].unit_min)							
							
							hoverflag_4 = false
							CPU_units[n].attacked = true
							get_node("../BattleManager").check_health_now()	
																
							await get_tree().create_timer(0.5).timeout
							
			await get_tree().create_timer(0.1).timeout
																
			hoverflag_4 = true							 						
			structure_flag4_ranged = true
				
			await get_tree().create_timer(1).timeout
			
		#Erase hover tiles
		for j in 16:
			for k in 16:
				get_node("../TileMap").set_cell(1, Vector2i(j,k), -1, Vector2i(0, 0), 0)
		
		# CPU Movement range
		if get_node("../BattleManager").CPU_units[n].attacked == false and CPU_units[n].unit_status == "Active":					
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

			if get_node("../BattleManager").CPU_units[n].unit_movement == 5:
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

				get_node("../TileMap").set_cell(1, Vector2i(unit_target_pos.x+2, unit_target_pos.y+3), 18, Vector2i(0, 0), 0)																																								
				get_node("../TileMap").set_cell(1, Vector2i(unit_target_pos.x-3, unit_target_pos.y-2), 18, Vector2i(0, 0), 0)															
				get_node("../TileMap").set_cell(1, Vector2i(unit_target_pos.x+2, unit_target_pos.y-3), 18, Vector2i(0, 0), 0)																																								
				get_node("../TileMap").set_cell(1, Vector2i(unit_target_pos.x-3, unit_target_pos.y+2), 18, Vector2i(0, 0), 0)

				get_node("../TileMap").set_cell(1, Vector2i(unit_target_pos.x+3, unit_target_pos.y+2), 18, Vector2i(0, 0), 0)																																								
				get_node("../TileMap").set_cell(1, Vector2i(unit_target_pos.x-2, unit_target_pos.y-3), 18, Vector2i(0, 0), 0)															
				get_node("../TileMap").set_cell(1, Vector2i(unit_target_pos.x+3, unit_target_pos.y-2), 18, Vector2i(0, 0), 0)																																								
				get_node("../TileMap").set_cell(1, Vector2i(unit_target_pos.x-2, unit_target_pos.y+3), 18, Vector2i(0, 0), 0)
												
			await get_tree().create_timer(0.1).timeout
			#Check if and else
			for m in USER_units.size():
				var user_pos = get_node("../TileMap").local_to_map(USER_units[m].position)
				if USER_units[m].unit_status == "Active":
					if get_node("../TileMap").get_cell_source_id(1, user_pos) == 18:
						user_check = true
						var surrounding_cells_array = get_node("../TileMap").get_surrounding_cells(user_pos)
						var target_random_cell = rng.randi_range(0, surrounding_cells_array.size())
						
						if target_random_cell >= 4:
							target_random_cell -= 1
							
						var cell_available = false 
						while cell_available == false:
							if get_node("../TileMap").astar_grid.is_point_solid(surrounding_cells_array[target_random_cell]) == false:
								cell_available = true
							else:
								#CPU_units[n].get_child(9).show()
								target_random_cell = rng.randi_range(0, surrounding_cells_array.size())
								if target_random_cell >= 4:
									target_random_cell -= 1
																
						# Find Path
						var patharray = get_node("../TileMap").astar_grid.get_point_path(unit_target_pos, surrounding_cells_array[target_random_cell])

						await get_tree().create_timer(1).timeout
						#Erase hover tiles
						for j in 16:
							for k in 16:
								get_node("../TileMap").set_cell(1, Vector2i(j,k), -1, Vector2i(0, 0), 0)
						
						# Set hover cells
						for h in patharray.size():
							await get_tree().create_timer(0.01).timeout
							get_node("../TileMap").set_cell(1, patharray[h], 18, Vector2i(0, 0), 0)	
						
						get_node("../BattleManager").CPU_units[n].get_child(0).play("move")
						
						# Move unit		
						for h in patharray.size():
							var tile_center_pos = get_node("../TileMap").map_to_local(patharray[h]) + Vector2(0,0) / 2
							var tween = create_tween()
							var cpu_unit_pos = get_node("../TileMap").local_to_map(get_node("../BattleManager").CPU_units[n].position)
							get_node("../BattleManager").CPU_units[n].z_index = cpu_unit_pos.x + cpu_unit_pos.y		
							tween.tween_property(get_node("../BattleManager").CPU_units[n], "position", tile_center_pos, 0.25)				
							get_node("../TileMap").get_child(1).stream = get_node("../TileMap").map_sfx[2]
							get_node("../TileMap").get_child(1).play()	
							await get_tree().create_timer(0.25).timeout		
													
						get_node("../BattleManager").CPU_units[n].get_child(0).play("default")	
						
						await get_tree().create_timer(0.1).timeout
						get_node("../BattleManager").CPU_units[n].moved = true	
							
						#Erase hover tiles
						for j in 16:
							for k in 16:
								get_node("../TileMap").set_cell(1, Vector2i(j,k), -1, Vector2i(0, 0), 0)		

						get_node("../BattleManager").CPU_units[n].get_child(0).play("default")	

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
										get_node("../BattleManager").USER_units[j].unit_min -= get_node("../BattleManager").CPU_units[n].unit_level - get_node("../BattleManager").USER_units[m].unit_defence
										get_node("../BattleManager").USER_units[j].progressbar.set_value(get_node("../BattleManager").USER_units[j].unit_min)
										#print("A")
										print('CPU moved')
										check_health_now()
										await get_tree().create_timer(1).timeout
										get_node("../BattleManager").check_health_now()
										get_node("../BattleManager").CPU_units[n].attacked = true							
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
										get_node("../BattleManager").USER_units[j].unit_min -= get_node("../BattleManager").CPU_units[n].unit_level - get_node("../BattleManager").USER_units[m].unit_defence
										get_node("../BattleManager").USER_units[j].progressbar.set_value(get_node("../BattleManager").USER_units[j].unit_min)
										#print("A")
										print('CPU moved')
										check_health_now()
										await get_tree().create_timer(1).timeout
										get_node("../BattleManager").check_health_now()
										get_node("../BattleManager").CPU_units[n].attacked = true							
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
										get_node("../BattleManager").USER_units[j].unit_min -= get_node("../BattleManager").CPU_units[n].unit_level - get_node("../BattleManager").USER_units[m].unit_defence
										get_node("../BattleManager").USER_units[j].progressbar.set_value(get_node("../BattleManager").USER_units[j].unit_min)
										#print("A")
										print('CPU moved')
										check_health_now()
										await get_tree().create_timer(1).timeout
										get_node("../BattleManager").check_health_now()
										get_node("../BattleManager").CPU_units[n].attacked = true							
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
										get_node("../BattleManager").USER_units[j].unit_min -= get_node("../BattleManager").CPU_units[n].unit_level - get_node("../BattleManager").USER_units[m].unit_defence
										get_node("../BattleManager").USER_units[j].progressbar.set_value(get_node("../BattleManager").USER_units[j].unit_min)
										#print("A")
										print('CPU moved')	
										check_health_now()
										await get_tree().create_timer(1).timeout
										get_node("../BattleManager").check_health_now()														
										get_node("../BattleManager").CPU_units[n].attacked = true
										break																
						break																																								 											

					else:
						user_within = true
				else:
					pass
					
			#Remove hover tiles										
			for j in 16:
				for k in 16:
					get_node("../TileMap").set_cell(1, Vector2i(j,k), -1, Vector2i(0, 0), 0)

			for m in USER_units.size():
				var user_pos = get_node("../TileMap").local_to_map(USER_units[m].position)
				if USER_units[m].unit_status == "Active" and user_within == true and user_check == false:
					if get_node("../TileMap").get_cell_source_id(1, user_pos) == -1:
						var surrounding_cells_array = get_node("../TileMap").get_surrounding_cells(get_node("../TileMap").local_to_map(USER_units[m].get_closest_player_or_null_CPU().position))
						var target_random_cell = rng.randi_range(0, surrounding_cells_array.size())
						
						if target_random_cell >= 4:
							target_random_cell -= 1
													
						var cell_available = false 
						while cell_available == false:
							if get_node("../TileMap").astar_grid.is_point_solid(surrounding_cells_array[target_random_cell]) == false:
								cell_available = true														
							else:
								#CPU_units[n].get_child(9).show()
								target_random_cell = rng.randi_range(0, surrounding_cells_array.size())
								if target_random_cell >= 4:
									target_random_cell -= 1
								
						# Find Path
						var patharray = get_node("../TileMap").astar_grid.get_point_path(unit_target_pos, surrounding_cells_array[target_random_cell])

						await get_tree().create_timer(1).timeout
						#Erase hover tiles
						for j in 16:
							for k in 16:
								get_node("../TileMap").set_cell(1, Vector2i(j,k), -1, Vector2i(0, 0), 0)
						
						# Set hover cells
						for h in patharray.size():
							await get_tree().create_timer(0.01).timeout
							get_node("../TileMap").set_cell(1, patharray[h], 18, Vector2i(0, 0), 0)	
							if h == CPU_units[n].unit_movement:
								break
						
						get_node("../BattleManager").CPU_units[n].get_child(0).play("move")
						
						# Move unit		
						for h in patharray.size():
							var tile_center_pos = get_node("../TileMap").map_to_local(patharray[h]) + Vector2(0,0) / 2
							var tween = create_tween()
							var cpu_unit_pos = get_node("../TileMap").local_to_map(get_node("../BattleManager").CPU_units[n].position)
							get_node("../BattleManager").CPU_units[n].z_index = cpu_unit_pos.x + cpu_unit_pos.y		
							tween.tween_property(get_node("../BattleManager").CPU_units[n], "position", tile_center_pos, 0.25)				
							get_node("../TileMap").get_child(1).stream = get_node("../TileMap").map_sfx[2]
							get_node("../TileMap").get_child(1).play()	
							await get_tree().create_timer(0.25).timeout		
							if h == CPU_units[n].unit_movement:
								break		
												
						get_node("../BattleManager").CPU_units[n].get_child(0).play("default")	
						
						await get_tree().create_timer(0.1).timeout
						get_node("../BattleManager").CPU_units[n].moved = true
							
						#Erase hover tiles
						for j in 16:
							for k in 16:
								get_node("../TileMap").set_cell(1, Vector2i(j,k), -1, Vector2i(0, 0), 0)		

						get_node("../BattleManager").CPU_units[n].get_child(0).play("default")	

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
										get_node("../BattleManager").USER_units[j].unit_min -= get_node("../BattleManager").CPU_units[n].unit_level - get_node("../BattleManager").USER_units[m].unit_defence
										get_node("../BattleManager").USER_units[j].progressbar.set_value(get_node("../BattleManager").USER_units[j].unit_min)
										#print("A")
										print('CPU moved')
										check_health_now()
										await get_tree().create_timer(0.1).timeout
										get_node("../BattleManager").check_health_now()
										get_node("../BattleManager").CPU_units[n].attacked = true							
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
										get_node("../BattleManager").USER_units[j].unit_min -= get_node("../BattleManager").CPU_units[n].unit_level - get_node("../BattleManager").USER_units[m].unit_defence
										get_node("../BattleManager").USER_units[j].progressbar.set_value(get_node("../BattleManager").USER_units[j].unit_min)
										#print("A")
										print('CPU moved')
										check_health_now()
										await get_tree().create_timer(0.1).timeout
										get_node("../BattleManager").check_health_now()
										get_node("../BattleManager").CPU_units[n].attacked = true							
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
										get_node("../BattleManager").USER_units[j].unit_min -= get_node("../BattleManager").CPU_units[n].unit_level - get_node("../BattleManager").USER_units[m].unit_defence
										get_node("../BattleManager").USER_units[j].progressbar.set_value(get_node("../BattleManager").USER_units[j].unit_min)
										#print("A")
										print('CPU moved')
										check_health_now()
										await get_tree().create_timer(0.1).timeout
										get_node("../BattleManager").check_health_now()
										get_node("../BattleManager").CPU_units[n].attacked = true							
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
										get_node("../BattleManager").USER_units[j].unit_min -= get_node("../BattleManager").CPU_units[n].unit_level - get_node("../BattleManager").USER_units[m].unit_defence
										get_node("../BattleManager").USER_units[j].progressbar.set_value(get_node("../BattleManager").USER_units[j].unit_min)
										#print("A")
										print('CPU moved')	
										check_health_now()
										await get_tree().create_timer(0.1).timeout
										get_node("../BattleManager").check_health_now()														
										get_node("../BattleManager").CPU_units[n].attacked = true
										break	
																
						break
					else:
						pass
				else:
					pass
					
			user_within = false
			user_check = false
			
			#Check range again	
			cpu_pos = get_node("../TileMap").local_to_map(get_node("../BattleManager").CPU_units[n].position)	
			if unit_type == "Ranged" and CPU_units[n].unit_status == "Active" and CPU_units[n].attacked == false:	
				get_node("../TileMap").get_child(1).stream = get_node("../TileMap").map_sfx[1]
				get_node("../TileMap").get_child(1).play()																		
				for j in 16:	
					get_node("../TileMap").set_cell(1, cpu_pos, -1, Vector2i(0, 0), 0)
					if hoverflag_1 == true and structure_flag1_ranged == true:
						get_node("../TileMap").set_cell(1, Vector2i(cpu_pos.x-j, cpu_pos.y), 48, Vector2i(0, 0), 0)
						#await get_tree().create_timer(0).timeout
						for h in node2D.structures.size():
							var set_cell = Vector2i(cpu_pos.x-j, cpu_pos.y)
							var structure_pos = get_node("../TileMap").local_to_map(node2D.structures[h].position)
							#print(set_cell, structure_pos)
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
								await SetLinePoints(line_2d, CPU_units[n].get_node("Emitter").global_position, Vector2(0,0), Vector2(0,0), get_node("../BattleManager").USER_units[m].get_node("Emitter").global_position)							
								var _bumpedvector = get_node("../TileMap").local_to_map(USER_units[m].position)
								var _newvector = Vector2i(_bumpedvector.x-1, _bumpedvector.y)
								var _finalvector = get_node("../TileMap").map_to_local(_newvector) + Vector2(0,0) / 2
								
								get_node("../BattleManager").USER_units[m].position = _finalvector
								var tween: Tween = create_tween()
								tween.tween_property(get_node("../BattleManager").USER_units[m], "modulate:v", 1, 0.50).from(5)							
								
								get_node("../BattleManager").USER_units[m].unit_min -= CPU_units[n].unit_level - get_node("../BattleManager").USER_units[m].unit_defence
								CPU_units[n].xp += 1
								get_node("../BattleManager").USER_units[m].progressbar.set_value(get_node("../BattleManager").USER_units[m].unit_min)							
								
								hoverflag_1 = false
								CPU_units[n].attacked = true
								get_node("../BattleManager").check_health_now()
				
								await get_tree().create_timer(0.5).timeout
															
				await get_tree().create_timer(0.1).timeout	

				hoverflag_1 = true
				structure_flag1_ranged = true													
				for j in 16:	
					get_node("../TileMap").set_cell(1, cpu_pos, -1, Vector2i(0, 0), 0)
					if hoverflag_2 == true and structure_flag2_ranged == true:
						get_node("../TileMap").set_cell(1, Vector2i(cpu_pos.x, cpu_pos.y+j), 48, Vector2i(0, 0), 0)
						#await get_tree().create_timer(0).timeout
						for h in node2D.structures.size():
							var set_cell = Vector2i(cpu_pos.x, cpu_pos.y+j)
							var structure_pos = get_node("../TileMap").local_to_map(node2D.structures[h].position)
							#print(set_cell, structure_pos)
							if set_cell == structure_pos:
								structure_flag2_ranged = false
						for m in USER_units.size():
							var user_pos = get_node("../TileMap").local_to_map(USER_units[m].position)	
							if get_node("../TileMap").get_cell_source_id(1, user_pos) == 48 and CPU_units[n].attacked == false:
								get_node("../BattleManager").CPU_units[n].get_child(0).play("attack")	
								await get_tree().create_timer(0.7).timeout
								get_node("../BattleManager").CPU_units[n].get_child(0).play("default")			
								await SetLinePoints(line_2d, CPU_units[n].get_node("Emitter").global_position, Vector2(0,0), Vector2(0,0), get_node("../BattleManager").USER_units[m].get_node("Emitter").global_position)							

								var _bumpedvector = get_node("../TileMap").local_to_map(USER_units[m].position)
								var _newvector = Vector2i(_bumpedvector.x, _bumpedvector.y+1)
								var _finalvector = get_node("../TileMap").map_to_local(_newvector) + Vector2(0,0) / 2
								
								get_node("../BattleManager").USER_units[m].position = _finalvector
								var tween: Tween = create_tween()
								tween.tween_property(get_node("../BattleManager").USER_units[m], "modulate:v", 1, 0.50).from(5)							

								get_node("../BattleManager").USER_units[m].unit_min -= CPU_units[n].unit_level - get_node("../BattleManager").USER_units[m].unit_defence
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
							#print(set_cell, structure_pos)
							if set_cell == structure_pos:
								structure_flag3_ranged = false
						for m in USER_units.size():
							var user_pos = get_node("../TileMap").local_to_map(USER_units[m].position)	
							if get_node("../TileMap").get_cell_source_id(1, user_pos) == 48 and CPU_units[n].attacked == false:
								get_node("../BattleManager").CPU_units[n].get_child(0).play("attack")	
								await get_tree().create_timer(0.7).timeout
								get_node("../BattleManager").CPU_units[n].get_child(0).play("default")			
								await SetLinePoints(line_2d, CPU_units[n].get_node("Emitter").global_position, Vector2(0,0), Vector2(0,0), get_node("../BattleManager").USER_units[m].get_node("Emitter").global_position)							
								
								var _bumpedvector = get_node("../TileMap").local_to_map(USER_units[m].position)
								var _newvector = Vector2i(_bumpedvector.x+1, _bumpedvector.y)
								var _finalvector = get_node("../TileMap").map_to_local(_newvector) + Vector2(0,0) / 2
								
								get_node("../BattleManager").USER_units[m].position = _finalvector
								var tween: Tween = create_tween()
								tween.tween_property(get_node("../BattleManager").USER_units[m], "modulate:v", 1, 0.50).from(5)							

								get_node("../BattleManager").USER_units[m].unit_min -= CPU_units[n].unit_level - get_node("../BattleManager").USER_units[m].unit_defence
								CPU_units[n].xp += 1
								get_node("../BattleManager").USER_units[m].progressbar.set_value(get_node("../BattleManager").USER_units[m].unit_min)							
								
								hoverflag_3 = false
								CPU_units[n].attacked = true
								get_node("../BattleManager").check_health_now()
								
								await get_tree().create_timer(0.5).timeout
								
				await get_tree().create_timer(0.1).timeout
								
				hoverflag_3 = true	
				structure_flag3_ranged = true													
				for j in 16:	
					get_node("../TileMap").set_cell(1, cpu_pos, -1, Vector2i(0, 0), 0)
					if hoverflag_4 == true and structure_flag4_ranged == true:
						get_node("../TileMap").set_cell(1, Vector2i(cpu_pos.x, cpu_pos.y-j), 48, Vector2i(0, 0), 0)
						#await get_tree().create_timer(0).timeout
						for h in node2D.structures.size():
							var set_cell = Vector2i(cpu_pos.x, cpu_pos.y-j)
							var structure_pos = get_node("../TileMap").local_to_map(node2D.structures[h].position)
							#print(set_cell, structure_pos)
							if set_cell == structure_pos:
								structure_flag4_ranged = false
						for m in USER_units.size():
							var user_pos = get_node("../TileMap").local_to_map(USER_units[m].position)	
							if get_node("../TileMap").get_cell_source_id(1, user_pos) == 48 and CPU_units[n].attacked == false:
								get_node("../BattleManager").CPU_units[n].get_child(0).play("attack")	
								await get_tree().create_timer(0.7).timeout
								get_node("../BattleManager").CPU_units[n].get_child(0).play("default")			
								await SetLinePoints(line_2d, CPU_units[n].get_node("Emitter").global_position, Vector2(0,0), Vector2(0,0), get_node("../BattleManager").USER_units[m].get_node("Emitter").global_position)							

								var _bumpedvector = get_node("../TileMap").local_to_map(USER_units[m].position)
								var _newvector = Vector2i(_bumpedvector.x, _bumpedvector.y-1)
								var _finalvector = get_node("../TileMap").map_to_local(_newvector) + Vector2(0,0) / 2
								
								get_node("../BattleManager").USER_units[m].position = _finalvector
								var tween: Tween = create_tween()
								tween.tween_property(get_node("../BattleManager").USER_units[m], "modulate:v", 1, 0.50).from(5)							

								get_node("../BattleManager").USER_units[m].unit_min -= CPU_units[n].unit_level - get_node("../BattleManager").USER_units[m].unit_defence
								CPU_units[n].xp += 1
								get_node("../BattleManager").USER_units[m].progressbar.set_value(get_node("../BattleManager").USER_units[m].unit_min)							
								
								hoverflag_4 = false
								CPU_units[n].attacked = true
								get_node("../BattleManager").check_health_now()	
																	
								await get_tree().create_timer(0.5).timeout
								
				await get_tree().create_timer(0.1).timeout
																	
				hoverflag_4 = true							 						
				structure_flag4_ranged = true
					
				await get_tree().create_timer(0.1).timeout
				
				#Remove hover tiles										
				for j in 16:
					for k in 16:
						get_node("../TileMap").set_cell(1, Vector2i(j,k), -1, Vector2i(0, 0), 0)				

			elif CPU_units[n].unit_status == "Inactive":
				for k in get_node("../BattleManager").USER_units.size():
					get_node("../BattleManager").USER_units[k].moved = false
					get_node("../BattleManager").USER_units[k].attacked = false
					get_node("../TileMap").moves_counter = 0
										
					
		elif CPU_units[n].unit_status == "Inactive":
			for k in get_node("../BattleManager").USER_units.size():
				get_node("../BattleManager").USER_units[k].moved = false
				get_node("../BattleManager").USER_units[k].attacked = false
				get_node("../TileMap").moves_counter = 0	
								
							
	for k in get_node("../BattleManager").available_units.size():
		get_node("../BattleManager").available_units[k].moved = false
		get_node("../BattleManager").available_units[k].attacked = false
		get_node("../TileMap").moves_counter = 0

	for n in CPU_units.size():
		if CPU_units[n].unit_status == "Active":
			CPU_units[n].get_child(9).hide()			
		
	get_node("../TileMap").hovertile.offset.y = 0	

	get_node("../BattleManager").check_health_now()
	
	get_node("../Control").get_child(19).text = "USER TURN"
	#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_node("../Control").get_child(18).show() # moves count
	get_node("../Hover_tile").show()
	
	get_node("../TileMap").moving = false

	for i in available_units.size():
		available_units[i].check_health()
	
	if ai_mode_bool == true:
		on_user_ai_started()
	else:
		turn_button.show()

func on_user_ai_started() -> void:		
	get_node("../Control").get_child(19).text = "USER Moving..."
	get_node("../Control").get_child(18).hide() # moves count
	get_node("../TileMap").hovertile.hide()
	#Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	get_node("../TileMap").moving = true
	
	for i in get_node("../BattleManager").available_units.size():
		get_node("../BattleManager").available_units[i].moved = false
		get_node("../BattleManager").available_units[i].attacked = false
		get_node("../TileMap").moves_counter = 0
		
	get_node("../BattleManager").structure_flag1_ranged = true
	get_node("../BattleManager").structure_flag2_ranged = true
	get_node("../BattleManager").structure_flag3_ranged = true
	get_node("../BattleManager").structure_flag4_ranged = true
			
	available_units = get_tree().get_nodes_in_group("mek_scenes")	
	
	for i in available_units.size():
		available_units[i].check_health()
		
	#Remove hover tiles										
	for j in 16:
		for k in 16:
			get_node("../TileMap").set_cell(1, Vector2i(j,k), -1, Vector2i(0, 0), 0)		
	
	print('USER turn')	
	
	for i in available_units.size():
		if available_units[i].unit_team == 2:
			available_units[i].add_to_group("CPU_Team")
		if available_units[i].unit_team == 1:
			available_units[i].add_to_group("USER_Team")
				
	USER_units = get_tree().get_nodes_in_group("CPU_Team")
	CPU_units = get_tree().get_nodes_in_group("USER_Team")	

	# CPU Check Attack Range
	for n in CPU_units.size():
		cpu_pos = get_node("../TileMap").local_to_map(get_node("../BattleManager").CPU_units[n].position)

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
						#print(set_cell, structure_pos)
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
							await SetLinePoints(line_2d, CPU_units[n].get_node("Emitter").global_position, Vector2(0,0), Vector2(0,0), get_node("../BattleManager").USER_units[m].get_node("Emitter").global_position)							
							var _bumpedvector = get_node("../TileMap").local_to_map(USER_units[m].position)
							var _newvector = Vector2i(_bumpedvector.x-1, _bumpedvector.y)
							var _finalvector = get_node("../TileMap").map_to_local(_newvector) + Vector2(0,0) / 2
							
							get_node("../BattleManager").USER_units[m].position = _finalvector
							var tween: Tween = create_tween()
							tween.tween_property(get_node("../BattleManager").USER_units[m], "modulate:v", 1, 0.50).from(5)							
							
							get_node("../BattleManager").USER_units[m].unit_min -= CPU_units[n].unit_level - get_node("../BattleManager").USER_units[m].unit_defence
							CPU_units[n].xp += 1
							get_node("../BattleManager").USER_units[m].progressbar.set_value(get_node("../BattleManager").USER_units[m].unit_min)							
							
							hoverflag_1 = false
							CPU_units[n].attacked = true
							get_node("../BattleManager").check_health_now()
			
							await get_tree().create_timer(0.5).timeout
														
			await get_tree().create_timer(0.1).timeout	

			hoverflag_1 = true
			structure_flag1_ranged = true													
			for j in 16:	
				get_node("../TileMap").set_cell(1, cpu_pos, -1, Vector2i(0, 0), 0)
				if hoverflag_2 == true and structure_flag2_ranged == true:
					get_node("../TileMap").set_cell(1, Vector2i(cpu_pos.x, cpu_pos.y+j), 48, Vector2i(0, 0), 0)
					#await get_tree().create_timer(0).timeout
					for h in node2D.structures.size():
						var set_cell = Vector2i(cpu_pos.x, cpu_pos.y+j)
						var structure_pos = get_node("../TileMap").local_to_map(node2D.structures[h].position)
						#print(set_cell, structure_pos)
						if set_cell == structure_pos:
							structure_flag2_ranged = false
					for m in USER_units.size():
						var user_pos = get_node("../TileMap").local_to_map(USER_units[m].position)	
						if get_node("../TileMap").get_cell_source_id(1, user_pos) == 48 and CPU_units[n].attacked == false:
							get_node("../BattleManager").CPU_units[n].get_child(0).play("attack")	
							await get_tree().create_timer(0.7).timeout
							get_node("../BattleManager").CPU_units[n].get_child(0).play("default")			
							await SetLinePoints(line_2d, CPU_units[n].get_node("Emitter").global_position, Vector2(0,0), Vector2(0,0), get_node("../BattleManager").USER_units[m].get_node("Emitter").global_position)							

							var _bumpedvector = get_node("../TileMap").local_to_map(USER_units[m].position)
							var _newvector = Vector2i(_bumpedvector.x, _bumpedvector.y+1)
							var _finalvector = get_node("../TileMap").map_to_local(_newvector) + Vector2(0,0) / 2
							
							get_node("../BattleManager").USER_units[m].position = _finalvector
							var tween: Tween = create_tween()
							tween.tween_property(get_node("../BattleManager").USER_units[m], "modulate:v", 1, 0.50).from(5)							

							get_node("../BattleManager").USER_units[m].unit_min -= CPU_units[n].unit_level - get_node("../BattleManager").USER_units[m].unit_defence
							CPU_units[n].xp += 1
							get_node("../BattleManager").USER_units[m].progressbar.set_value(get_node("../BattleManager").USER_units[m].unit_min)							
							
							hoverflag_2 = false
							CPU_units[n].attacked = true
							get_node("../BattleManager").check_health_now()
							
							await get_tree().create_timer(0.5).timeout
							
			await get_tree().create_timer(0.1).timeout
			
			hoverflag_2 = true	
			structure_flag2_ranged = true											
			for j in 16:	
				get_node("../TileMap").set_cell(1, cpu_pos, -1, Vector2i(0, 0), 0)
				if hoverflag_3 == true and structure_flag3_ranged == true:
					get_node("../TileMap").set_cell(1, Vector2i(cpu_pos.x+j, cpu_pos.y), 48, Vector2i(0, 0), 0)
					#await get_tree().create_timer(0).timeout
					for h in node2D.structures.size():
						var set_cell = Vector2i(cpu_pos.x+j, cpu_pos.y)
						var structure_pos = get_node("../TileMap").local_to_map(node2D.structures[h].position)
						#print(set_cell, structure_pos)
						if set_cell == structure_pos:
							structure_flag3_ranged = false
					for m in USER_units.size():
						var user_pos = get_node("../TileMap").local_to_map(USER_units[m].position)	
						if get_node("../TileMap").get_cell_source_id(1, user_pos) == 48 and CPU_units[n].attacked == false:
							get_node("../BattleManager").CPU_units[n].get_child(0).play("attack")	
							await get_tree().create_timer(0.7).timeout
							get_node("../BattleManager").CPU_units[n].get_child(0).play("default")			
							await SetLinePoints(line_2d, CPU_units[n].get_node("Emitter").global_position, Vector2(0,0), Vector2(0,0), get_node("../BattleManager").USER_units[m].get_node("Emitter").global_position)							
							
							var _bumpedvector = get_node("../TileMap").local_to_map(USER_units[m].position)
							var _newvector = Vector2i(_bumpedvector.x+1, _bumpedvector.y)
							var _finalvector = get_node("../TileMap").map_to_local(_newvector) + Vector2(0,0) / 2
							
							get_node("../BattleManager").USER_units[m].position = _finalvector
							var tween: Tween = create_tween()
							tween.tween_property(get_node("../BattleManager").USER_units[m], "modulate:v", 1, 0.50).from(5)							

							get_node("../BattleManager").USER_units[m].unit_min -= CPU_units[n].unit_level - get_node("../BattleManager").USER_units[m].unit_defence
							CPU_units[n].xp += 1
							get_node("../BattleManager").USER_units[m].progressbar.set_value(get_node("../BattleManager").USER_units[m].unit_min)							
							
							hoverflag_3 = false
							CPU_units[n].attacked = true
							get_node("../BattleManager").check_health_now()
							
							await get_tree().create_timer(0.5).timeout
							
			await get_tree().create_timer(0.1).timeout
							
			hoverflag_3 = true	
			structure_flag3_ranged = true													
			for j in 16:	
				get_node("../TileMap").set_cell(1, cpu_pos, -1, Vector2i(0, 0), 0)
				if hoverflag_4 == true and structure_flag4_ranged == true:
					get_node("../TileMap").set_cell(1, Vector2i(cpu_pos.x, cpu_pos.y-j), 48, Vector2i(0, 0), 0)
					#await get_tree().create_timer(0).timeout
					for h in node2D.structures.size():
						var set_cell = Vector2i(cpu_pos.x, cpu_pos.y-j)
						var structure_pos = get_node("../TileMap").local_to_map(node2D.structures[h].position)
						#print(set_cell, structure_pos)
						if set_cell == structure_pos:
							structure_flag4_ranged = false
					for m in USER_units.size():
						var user_pos = get_node("../TileMap").local_to_map(USER_units[m].position)	
						if get_node("../TileMap").get_cell_source_id(1, user_pos) == 48 and CPU_units[n].attacked == false:
							get_node("../BattleManager").CPU_units[n].get_child(0).play("attack")	
							await get_tree().create_timer(0.7).timeout
							get_node("../BattleManager").CPU_units[n].get_child(0).play("default")			
							await SetLinePoints(line_2d, CPU_units[n].get_node("Emitter").global_position, Vector2(0,0), Vector2(0,0), get_node("../BattleManager").USER_units[m].get_node("Emitter").global_position)							

							var _bumpedvector = get_node("../TileMap").local_to_map(USER_units[m].position)
							var _newvector = Vector2i(_bumpedvector.x, _bumpedvector.y-1)
							var _finalvector = get_node("../TileMap").map_to_local(_newvector) + Vector2(0,0) / 2
							
							get_node("../BattleManager").USER_units[m].position = _finalvector
							var tween: Tween = create_tween()
							tween.tween_property(get_node("../BattleManager").USER_units[m], "modulate:v", 1, 0.50).from(5)							

							get_node("../BattleManager").USER_units[m].unit_min -= CPU_units[n].unit_level - get_node("../BattleManager").USER_units[m].unit_defence
							CPU_units[n].xp += 1
							get_node("../BattleManager").USER_units[m].progressbar.set_value(get_node("../BattleManager").USER_units[m].unit_min)							
							
							hoverflag_4 = false
							CPU_units[n].attacked = true
							get_node("../BattleManager").check_health_now()	
																
							await get_tree().create_timer(0.5).timeout
							
			await get_tree().create_timer(0.1).timeout
																
			hoverflag_4 = true							 						
			structure_flag4_ranged = true
				
			await get_tree().create_timer(0.1).timeout
			
		#Erase hover tiles
		for j in 16:
			for k in 16:
				get_node("../TileMap").set_cell(1, Vector2i(j,k), -1, Vector2i(0, 0), 0)
		
		# CPU Movement range
		if get_node("../BattleManager").CPU_units[n].attacked == false and CPU_units[n].unit_status == "Active":					
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

			if get_node("../BattleManager").CPU_units[n].unit_movement == 5:
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

				get_node("../TileMap").set_cell(1, Vector2i(unit_target_pos.x+2, unit_target_pos.y+3), 18, Vector2i(0, 0), 0)																																								
				get_node("../TileMap").set_cell(1, Vector2i(unit_target_pos.x-3, unit_target_pos.y-2), 18, Vector2i(0, 0), 0)															
				get_node("../TileMap").set_cell(1, Vector2i(unit_target_pos.x+2, unit_target_pos.y-3), 18, Vector2i(0, 0), 0)																																								
				get_node("../TileMap").set_cell(1, Vector2i(unit_target_pos.x-3, unit_target_pos.y+2), 18, Vector2i(0, 0), 0)

				get_node("../TileMap").set_cell(1, Vector2i(unit_target_pos.x+3, unit_target_pos.y+2), 18, Vector2i(0, 0), 0)																																								
				get_node("../TileMap").set_cell(1, Vector2i(unit_target_pos.x-2, unit_target_pos.y-3), 18, Vector2i(0, 0), 0)															
				get_node("../TileMap").set_cell(1, Vector2i(unit_target_pos.x+3, unit_target_pos.y-2), 18, Vector2i(0, 0), 0)																																								
				get_node("../TileMap").set_cell(1, Vector2i(unit_target_pos.x-2, unit_target_pos.y+3), 18, Vector2i(0, 0), 0)
			
			await get_tree().create_timer(0.1).timeout
			#Check if and else
			for m in USER_units.size():
				var user_pos = get_node("../TileMap").local_to_map(USER_units[m].position)
				if USER_units[m].unit_status == "Active":
					if get_node("../TileMap").get_cell_source_id(1, user_pos) == 18:
						user_check = true
						var surrounding_cells_array = get_node("../TileMap").get_surrounding_cells(user_pos)
						var target_random_cell = rng.randi_range(0, surrounding_cells_array.size())
						
						if target_random_cell >= 4:
							target_random_cell -= 1
							
						var cell_available = false 
						while cell_available == false:
							if get_node("../TileMap").astar_grid.is_point_solid(surrounding_cells_array[target_random_cell]) == false:
								cell_available = true
							else:
								#CPU_units[n].get_child(9).show()
								target_random_cell = rng.randi_range(0, surrounding_cells_array.size())
								if target_random_cell >= 4:
									target_random_cell -= 1
																
						# Find Path
						var patharray = get_node("../TileMap").astar_grid.get_point_path(unit_target_pos, surrounding_cells_array[target_random_cell])

						await get_tree().create_timer(0.1).timeout
						#Erase hover tiles
						for j in 16:
							for k in 16:
								get_node("../TileMap").set_cell(1, Vector2i(j,k), -1, Vector2i(0, 0), 0)
						
						# Set hover cells
						for h in patharray.size():
							await get_tree().create_timer(0.01).timeout
							get_node("../TileMap").set_cell(1, patharray[h], 18, Vector2i(0, 0), 0)	
						
						get_node("../BattleManager").CPU_units[n].get_child(0).play("move")
						
						# Move unit		
						for h in patharray.size():
							var tile_center_pos = get_node("../TileMap").map_to_local(patharray[h]) + Vector2(0,0) / 2
							var tween = create_tween()
							var cpu_unit_pos = get_node("../TileMap").local_to_map(get_node("../BattleManager").CPU_units[n].position)
							get_node("../BattleManager").CPU_units[n].z_index = cpu_unit_pos.x + cpu_unit_pos.y		
							tween.tween_property(get_node("../BattleManager").CPU_units[n], "position", tile_center_pos, 0.25)				
							get_node("../TileMap").get_child(1).stream = get_node("../TileMap").map_sfx[2]
							get_node("../TileMap").get_child(1).play()	
							await get_tree().create_timer(0.25).timeout		
													
						get_node("../BattleManager").CPU_units[n].get_child(0).play("default")	
						
						await get_tree().create_timer(0.1).timeout
						get_node("../BattleManager").CPU_units[n].moved = true	
							
						#Erase hover tiles
						for j in 16:
							for k in 16:
								get_node("../TileMap").set_cell(1, Vector2i(j,k), -1, Vector2i(0, 0), 0)		

						get_node("../BattleManager").CPU_units[n].get_child(0).play("default")	

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
										get_node("../BattleManager").USER_units[j].unit_min -= get_node("../BattleManager").CPU_units[n].unit_level - get_node("../BattleManager").USER_units[m].unit_defence
										get_node("../BattleManager").USER_units[j].progressbar.set_value(get_node("../BattleManager").USER_units[j].unit_min)
										#print("A")
										print('CPU moved')
										check_health_now()
										await get_tree().create_timer(0.1).timeout
										get_node("../BattleManager").check_health_now()
										get_node("../BattleManager").CPU_units[n].attacked = true							
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
										get_node("../BattleManager").USER_units[j].unit_min -= get_node("../BattleManager").CPU_units[n].unit_level - get_node("../BattleManager").USER_units[m].unit_defence
										get_node("../BattleManager").USER_units[j].progressbar.set_value(get_node("../BattleManager").USER_units[j].unit_min)
										#print("A")
										print('CPU moved')
										check_health_now()
										await get_tree().create_timer(0.1).timeout
										get_node("../BattleManager").check_health_now()
										get_node("../BattleManager").CPU_units[n].attacked = true							
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
										get_node("../BattleManager").USER_units[j].unit_min -= get_node("../BattleManager").CPU_units[n].unit_level - get_node("../BattleManager").USER_units[m].unit_defence
										get_node("../BattleManager").USER_units[j].progressbar.set_value(get_node("../BattleManager").USER_units[j].unit_min)
										#print("A")
										print('CPU moved')
										check_health_now()
										await get_tree().create_timer(0.1).timeout
										get_node("../BattleManager").check_health_now()
										get_node("../BattleManager").CPU_units[n].attacked = true							
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
										get_node("../BattleManager").USER_units[j].unit_min -= get_node("../BattleManager").CPU_units[n].unit_level - get_node("../BattleManager").USER_units[m].unit_defence
										get_node("../BattleManager").USER_units[j].progressbar.set_value(get_node("../BattleManager").USER_units[j].unit_min)
										#print("A")
										print('CPU moved')	
										check_health_now()
										await get_tree().create_timer(0.1).timeout
										get_node("../BattleManager").check_health_now()														
										get_node("../BattleManager").CPU_units[n].attacked = true
										break																
						break																																								 											

					else:
						user_within = true
				else:
					pass
					
			#Remove hover tiles										
			for j in 16:
				for k in 16:
					get_node("../TileMap").set_cell(1, Vector2i(j,k), -1, Vector2i(0, 0), 0)

			for m in USER_units.size():
				var user_pos = get_node("../TileMap").local_to_map(USER_units[m].position)
				if USER_units[m].unit_status == "Active" and user_within == true and user_check == false:
					if get_node("../TileMap").get_cell_source_id(1, user_pos) == -1:
						var surrounding_cells_array = get_node("../TileMap").get_surrounding_cells(get_node("../TileMap").local_to_map(USER_units[m].get_closest_player_or_null_USER().position))
						var target_random_cell = rng.randi_range(0, surrounding_cells_array.size())
						
						if target_random_cell >= 4:
							target_random_cell -= 1
													
						var cell_available = false 
						while cell_available == false:
							if get_node("../TileMap").astar_grid.is_point_solid(surrounding_cells_array[target_random_cell]) == false:
								cell_available = true														
							else:
								#CPU_units[n].get_child(9).show()
								target_random_cell = rng.randi_range(0, surrounding_cells_array.size())
								if target_random_cell >= 4:
									target_random_cell -= 1
								
						# Find Path
						var patharray = get_node("../TileMap").astar_grid.get_point_path(unit_target_pos, surrounding_cells_array[target_random_cell])

						await get_tree().create_timer(0.1).timeout
						#Erase hover tiles
						for j in 16:
							for k in 16:
								get_node("../TileMap").set_cell(1, Vector2i(j,k), -1, Vector2i(0, 0), 0)
						
						# Set hover cells
						for h in patharray.size():
							await get_tree().create_timer(0.01).timeout
							get_node("../TileMap").set_cell(1, patharray[h], 18, Vector2i(0, 0), 0)	
							if h == CPU_units[n].unit_movement:
								break
						
						get_node("../BattleManager").CPU_units[n].get_child(0).play("move")
						
						# Move unit		
						for h in patharray.size():
							var tile_center_pos = get_node("../TileMap").map_to_local(patharray[h]) + Vector2(0,0) / 2
							var tween = create_tween()
							var cpu_unit_pos = get_node("../TileMap").local_to_map(get_node("../BattleManager").CPU_units[n].position)
							get_node("../BattleManager").CPU_units[n].z_index = cpu_unit_pos.x + cpu_unit_pos.y		
							tween.tween_property(get_node("../BattleManager").CPU_units[n], "position", tile_center_pos, 0.25)				
							get_node("../TileMap").get_child(1).stream = get_node("../TileMap").map_sfx[2]
							get_node("../TileMap").get_child(1).play()	
							await get_tree().create_timer(0.25).timeout		
							if h == CPU_units[n].unit_movement:
								break		
												
						get_node("../BattleManager").CPU_units[n].get_child(0).play("default")	
						
						await get_tree().create_timer(0.1).timeout
						get_node("../BattleManager").CPU_units[n].moved = true
							
						#Erase hover tiles
						for j in 16:
							for k in 16:
								get_node("../TileMap").set_cell(1, Vector2i(j,k), -1, Vector2i(0, 0), 0)		

						get_node("../BattleManager").CPU_units[n].get_child(0).play("default")	

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
										get_node("../BattleManager").USER_units[j].unit_min -= get_node("../BattleManager").CPU_units[n].unit_level - get_node("../BattleManager").USER_units[m].unit_defence
										get_node("../BattleManager").USER_units[j].progressbar.set_value(get_node("../BattleManager").USER_units[j].unit_min)
										#print("A")
										print('CPU moved')
										check_health_now()
										await get_tree().create_timer(0.1).timeout
										get_node("../BattleManager").check_health_now()
										get_node("../BattleManager").CPU_units[n].attacked = true							
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
										get_node("../BattleManager").USER_units[j].unit_min -= get_node("../BattleManager").CPU_units[n].unit_level - get_node("../BattleManager").USER_units[m].unit_defence
										get_node("../BattleManager").USER_units[j].progressbar.set_value(get_node("../BattleManager").USER_units[j].unit_min)
										#print("A")
										print('CPU moved')
										check_health_now()
										await get_tree().create_timer(0.1).timeout
										get_node("../BattleManager").check_health_now()
										get_node("../BattleManager").CPU_units[n].attacked = true							
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
										get_node("../BattleManager").USER_units[j].unit_min -= get_node("../BattleManager").CPU_units[n].unit_level - get_node("../BattleManager").USER_units[m].unit_defence
										get_node("../BattleManager").USER_units[j].progressbar.set_value(get_node("../BattleManager").USER_units[j].unit_min)
										#print("A")
										print('CPU moved')
										check_health_now()
										await get_tree().create_timer(0.1).timeout
										get_node("../BattleManager").check_health_now()
										get_node("../BattleManager").CPU_units[n].attacked = true							
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
										get_node("../BattleManager").USER_units[j].unit_min -= get_node("../BattleManager").CPU_units[n].unit_level - get_node("../BattleManager").USER_units[m].unit_defence
										get_node("../BattleManager").USER_units[j].progressbar.set_value(get_node("../BattleManager").USER_units[j].unit_min)
										#print("A")
										print('CPU moved')	
										check_health_now()
										await get_tree().create_timer(0.1).timeout
										get_node("../BattleManager").check_health_now()														
										get_node("../BattleManager").CPU_units[n].attacked = true
										break	
																
						break
					else:
						pass
				else:
					pass
					
			user_within = false
			user_check = false
			
			#Check range again	
			cpu_pos = get_node("../TileMap").local_to_map(get_node("../BattleManager").CPU_units[n].position)	
			if unit_type == "Ranged" and CPU_units[n].unit_status == "Active" and CPU_units[n].attacked == false:	
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
							#print(set_cell, structure_pos)
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
								await SetLinePoints(line_2d, CPU_units[n].get_node("Emitter").global_position, Vector2(0,0), Vector2(0,0), get_node("../BattleManager").USER_units[m].get_node("Emitter").global_position)							
								var _bumpedvector = get_node("../TileMap").local_to_map(USER_units[m].position)
								var _newvector = Vector2i(_bumpedvector.x-1, _bumpedvector.y)
								var _finalvector = get_node("../TileMap").map_to_local(_newvector) + Vector2(0,0) / 2
								
								get_node("../BattleManager").USER_units[m].position = _finalvector
								var tween: Tween = create_tween()
								tween.tween_property(get_node("../BattleManager").USER_units[m], "modulate:v", 1, 0.50).from(5)							
								
								get_node("../BattleManager").USER_units[m].unit_min -= CPU_units[n].unit_level - get_node("../BattleManager").USER_units[m].unit_defence
								CPU_units[n].xp += 1
								get_node("../BattleManager").USER_units[m].progressbar.set_value(get_node("../BattleManager").USER_units[m].unit_min)							
								
								hoverflag_1 = false
								CPU_units[n].attacked = true
								get_node("../BattleManager").check_health_now()
				
								await get_tree().create_timer(0.5).timeout
															
				await get_tree().create_timer(0.1).timeout	

				hoverflag_1 = true
				structure_flag1_ranged = true													
				for j in 16:	
					get_node("../TileMap").set_cell(1, cpu_pos, -1, Vector2i(0, 0), 0)
					if hoverflag_2 == true and structure_flag2_ranged == true:
						get_node("../TileMap").set_cell(1, Vector2i(cpu_pos.x, cpu_pos.y+j), 48, Vector2i(0, 0), 0)
						#await get_tree().create_timer(0).timeout
						for h in node2D.structures.size():
							var set_cell = Vector2i(cpu_pos.x, cpu_pos.y+j)
							var structure_pos = get_node("../TileMap").local_to_map(node2D.structures[h].position)
							#print(set_cell, structure_pos)
							if set_cell == structure_pos:
								structure_flag2_ranged = false
						for m in USER_units.size():
							var user_pos = get_node("../TileMap").local_to_map(USER_units[m].position)	
							if get_node("../TileMap").get_cell_source_id(1, user_pos) == 48 and CPU_units[n].attacked == false:
								get_node("../BattleManager").CPU_units[n].get_child(0).play("attack")	
								await get_tree().create_timer(0.7).timeout
								get_node("../BattleManager").CPU_units[n].get_child(0).play("default")			
								await SetLinePoints(line_2d, CPU_units[n].get_node("Emitter").global_position, Vector2(0,0), Vector2(0,0), get_node("../BattleManager").USER_units[m].get_node("Emitter").global_position)							

								var _bumpedvector = get_node("../TileMap").local_to_map(USER_units[m].position)
								var _newvector = Vector2i(_bumpedvector.x, _bumpedvector.y+1)
								var _finalvector = get_node("../TileMap").map_to_local(_newvector) + Vector2(0,0) / 2
								
								get_node("../BattleManager").USER_units[m].position = _finalvector
								var tween: Tween = create_tween()
								tween.tween_property(get_node("../BattleManager").USER_units[m], "modulate:v", 1, 0.50).from(5)							

								get_node("../BattleManager").USER_units[m].unit_min -= CPU_units[n].unit_level - get_node("../BattleManager").USER_units[m].unit_defence
								CPU_units[n].xp += 1
								get_node("../BattleManager").USER_units[m].progressbar.set_value(get_node("../BattleManager").USER_units[m].unit_min)							
								
								hoverflag_2 = false
								CPU_units[n].attacked = true
								get_node("../BattleManager").check_health_now()
								
								await get_tree().create_timer(0.5).timeout
								
				await get_tree().create_timer(0.1).timeout
				
				hoverflag_2 = true	
				structure_flag2_ranged = true											
				for j in 16:	
					get_node("../TileMap").set_cell(1, cpu_pos, -1, Vector2i(0, 0), 0)
					if hoverflag_3 == true and structure_flag3_ranged == true:
						get_node("../TileMap").set_cell(1, Vector2i(cpu_pos.x+j, cpu_pos.y), 48, Vector2i(0, 0), 0)
						#await get_tree().create_timer(0).timeout
						for h in node2D.structures.size():
							var set_cell = Vector2i(cpu_pos.x+j, cpu_pos.y)
							var structure_pos = get_node("../TileMap").local_to_map(node2D.structures[h].position)
							#print(set_cell, structure_pos)
							if set_cell == structure_pos:
								structure_flag3_ranged = false
						for m in USER_units.size():
							var user_pos = get_node("../TileMap").local_to_map(USER_units[m].position)	
							if get_node("../TileMap").get_cell_source_id(1, user_pos) == 48 and CPU_units[n].attacked == false:
								get_node("../BattleManager").CPU_units[n].get_child(0).play("attack")	
								await get_tree().create_timer(0.7).timeout
								get_node("../BattleManager").CPU_units[n].get_child(0).play("default")			
								await SetLinePoints(line_2d, CPU_units[n].get_node("Emitter").global_position, Vector2(0,0), Vector2(0,0), get_node("../BattleManager").USER_units[m].get_node("Emitter").global_position)							
								
								var _bumpedvector = get_node("../TileMap").local_to_map(USER_units[m].position)
								var _newvector = Vector2i(_bumpedvector.x+1, _bumpedvector.y)
								var _finalvector = get_node("../TileMap").map_to_local(_newvector) + Vector2(0,0) / 2
								
								get_node("../BattleManager").USER_units[m].position = _finalvector
								var tween: Tween = create_tween()
								tween.tween_property(get_node("../BattleManager").USER_units[m], "modulate:v", 1, 0.50).from(5)							

								get_node("../BattleManager").USER_units[m].unit_min -= CPU_units[n].unit_level - get_node("../BattleManager").USER_units[m].unit_defence
								CPU_units[n].xp += 1
								get_node("../BattleManager").USER_units[m].progressbar.set_value(get_node("../BattleManager").USER_units[m].unit_min)							
								
								hoverflag_3 = false
								CPU_units[n].attacked = true
								get_node("../BattleManager").check_health_now()
								
								await get_tree().create_timer(0.5).timeout
								
				await get_tree().create_timer(0.1).timeout
								
				hoverflag_3 = true	
				structure_flag3_ranged = true													
				for j in 16:	
					get_node("../TileMap").set_cell(1, cpu_pos, -1, Vector2i(0, 0), 0)
					if hoverflag_4 == true and structure_flag4_ranged == true:
						get_node("../TileMap").set_cell(1, Vector2i(cpu_pos.x, cpu_pos.y-j), 48, Vector2i(0, 0), 0)
						#await get_tree().create_timer(0).timeout
						for h in node2D.structures.size():
							var set_cell = Vector2i(cpu_pos.x, cpu_pos.y-j)
							var structure_pos = get_node("../TileMap").local_to_map(node2D.structures[h].position)
							#print(set_cell, structure_pos)
							if set_cell == structure_pos:
								structure_flag4_ranged = false
						for m in USER_units.size():
							var user_pos = get_node("../TileMap").local_to_map(USER_units[m].position)	
							if get_node("../TileMap").get_cell_source_id(1, user_pos) == 48 and CPU_units[n].attacked == false:
								get_node("../BattleManager").CPU_units[n].get_child(0).play("attack")	
								await get_tree().create_timer(0.7).timeout
								get_node("../BattleManager").CPU_units[n].get_child(0).play("default")			
								await SetLinePoints(line_2d, CPU_units[n].get_node("Emitter").global_position, Vector2(0,0), Vector2(0,0), get_node("../BattleManager").USER_units[m].get_node("Emitter").global_position)							

								var _bumpedvector = get_node("../TileMap").local_to_map(USER_units[m].position)
								var _newvector = Vector2i(_bumpedvector.x, _bumpedvector.y-1)
								var _finalvector = get_node("../TileMap").map_to_local(_newvector) + Vector2(0,0) / 2
								
								get_node("../BattleManager").USER_units[m].position = _finalvector
								var tween: Tween = create_tween()
								tween.tween_property(get_node("../BattleManager").USER_units[m], "modulate:v", 1, 0.50).from(5)							

								get_node("../BattleManager").USER_units[m].unit_min -= CPU_units[n].unit_level - get_node("../BattleManager").USER_units[m].unit_defence
								CPU_units[n].xp += 1
								get_node("../BattleManager").USER_units[m].progressbar.set_value(get_node("../BattleManager").USER_units[m].unit_min)							
								
								hoverflag_4 = false
								CPU_units[n].attacked = true
								get_node("../BattleManager").check_health_now()	
																	
								await get_tree().create_timer(0.5).timeout
								
				await get_tree().create_timer(0.1).timeout
																	
				hoverflag_4 = true							 						
				structure_flag4_ranged = true
					
				await get_tree().create_timer(0.1).timeout
				
				#Remove hover tiles										
				for j in 16:
					for k in 16:
						get_node("../TileMap").set_cell(1, Vector2i(j,k), -1, Vector2i(0, 0), 0)				

			elif CPU_units[n].unit_status == "Inactive":
				for k in get_node("../BattleManager").USER_units.size():
					get_node("../BattleManager").USER_units[k].moved = false
					get_node("../BattleManager").USER_units[k].attacked = false
					get_node("../TileMap").moves_counter = 0
										
					
		elif CPU_units[n].unit_status == "Inactive":
			for k in get_node("../BattleManager").USER_units.size():
				get_node("../BattleManager").USER_units[k].moved = false
				get_node("../BattleManager").USER_units[k].attacked = false
				get_node("../TileMap").moves_counter = 0	
								
							
	for k in get_node("../BattleManager").available_units.size():
		get_node("../BattleManager").available_units[k].moved = false
		get_node("../BattleManager").available_units[k].attacked = false
		get_node("../TileMap").moves_counter = 0

	for n in CPU_units.size():
		if CPU_units[n].unit_status == "Active":
			CPU_units[n].get_child(9).hide()			
		
	get_node("../TileMap").hovertile.offset.y = 0	

	get_node("../BattleManager").check_health_now()
	
	get_node("../Control").get_child(19).text = "CPU TURN"
	#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_node("../Control").get_child(18).show() # moves count
	get_node("../Hover_tile").show()
	
	#turn_button.show()
	get_node("../TileMap").moving = false

	for i in available_units.size():
		available_units[i].check_health()

	if inactive_total_cpu.size() == 5:
		return
	else:
		on_cpu_turn_started()
			
func on_turn_over() -> void:	
	get_node("../TurnManager").advance_turn()	
	
func get_random():
	_int = _int_full.duplicate()
	_int.shuffle()
	var random_int = _int.pop_front()
	return random_int	
	
func team_arrays():
	#randomize()
	#get_node("../BattleManager").available_units.shuffle()
		
	for i in available_units.size():
		available_units[i].unit_num = i
		available_units[i].add_to_group("ALL UNITS")
	
	for i in user_keys.size():
		user_dict[user_keys[i]].unit_team = 1
		user_dict[user_keys[i]].unit_status = "Active"
		user_dict[user_keys[i]].unit_type = "Ranged"	
			
	for i in available_units.size():		
		if available_units[i].unit_team != 1:
			available_units[i].unit_team = 2
			available_units[i].unit_status = "Active"		
			available_units[i].unit_type = "Ranged"	
			
																										
	for i in available_units.size():
		if available_units[i].unit_team == 1:
			# Team color
			get_node("../BattleManager").available_units[i].get_child(0).modulate = Color8(255, 255, 255)
			get_node("../BattleManager").available_units[i].unit_level = 1
			get_node("../BattleManager").available_units[i].unit_movement = 5
			get_node("../BattleManager").available_units[i].unit_defence = 0
			var unit_min_max = 3
			get_node("../BattleManager").available_units[i].unit_min = unit_min_max
			get_node("../BattleManager").available_units[i].unit_max = unit_min_max
			get_node("../BattleManager").available_units[i].progressbar.max_value = unit_min_max
			get_node("../BattleManager").available_units[i].xp_requirements = unit_min_max
			
		elif available_units[i].unit_team == 2:
			# Team color
			get_node("../BattleManager").available_units[i].get_child(0).modulate = Color8(255, 110, 255)
			get_node("../BattleManager").available_units[i].unit_level = 1
			get_node("../BattleManager").available_units[i].unit_movement = 5
			get_node("../BattleManager").available_units[i].unit_defence = 0
			var unit_min_max = 3
			get_node("../BattleManager").available_units[i].unit_min = unit_min_max
			get_node("../BattleManager").available_units[i].unit_max = unit_min_max
			get_node("../BattleManager").available_units[i].progressbar.max_value = unit_min_max
			get_node("../BattleManager").available_units[i].xp_requirements = unit_min_max
																		
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

	user_dict = {"M1": M1_inst, "M2": M2_inst, "M3": M3_inst, "R1": R1_inst, "R2": R2_inst, "R3": R3_inst, "R4": R4_inst, "S1": S1_inst, "S2": S2_inst, "S3": S3_inst}
	unit_tag_dict = {"M1": 0, "M2": 1, "M3": 2, "R1": 3, "R2": 4, "R3": 5, "R4": 6, "S1": 7, "S2": 8, "S3": 9}

func check_health_now():
	for z in available_units.size():
		available_units[z].check_health()		

func spawn():
	if teampick_count == 5:		
		spawning = true
		spawn_button.hide()
		picker.hide()
		
		await get_tree().create_timer(0).timeout
		spawn_meks()
		
		await get_tree().create_timer(0).timeout
		team_arrays()	

		await get_tree().create_timer(0).timeout	
		
		# Find open tiles	
		for i in 16:
			for j in 16:
				if get_node("../TileMap").astar_grid.is_point_solid(Vector2i(i,j)) == false:			
					open_tiles.append(Vector2i(i,j))
		
		random = get_random_numbers(0, open_tiles.size())
		
		# Drop units at start	
		for i in get_node("../BattleManager").available_units.size():		
			var new_position = get_node("../TileMap").map_to_local(open_tiles[random[i]]) + Vector2(0,0) / 2
			get_node("../BattleManager").available_units[i].position = Vector2(new_position.x, new_position.y-500)
			var tween: Tween = create_tween()
			tween.tween_property(get_node("../BattleManager").available_units[i], "position", new_position, 1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)	
			tween.connect("finished", on_tween_finished)
			await get_tree().create_timer(0.5).timeout
			if get_node("../BattleManager").available_units[i].unit_team == 2:
				picker.get_child(unit_tag_dict[get_node("../BattleManager").available_units[i].unit_tag]).show()
				picker.get_child(unit_tag_dict[get_node("../BattleManager").available_units[i].unit_tag]).scale = Vector2(1,1)
				#picker.get_child(unit_tag_dict[get_node("../BattleManager").available_units[i].unit_tag]).modulate = Color8(255, 110, 255)
			if get_node("../BattleManager").available_units[i].unit_team == 1:
				picker.get_child(unit_tag_dict[get_node("../BattleManager").available_units[i].unit_tag]).show()
				picker.get_child(unit_tag_dict[get_node("../BattleManager").available_units[i].unit_tag]).scale = Vector2(1,1)
				picker.get_child(unit_tag_dict[get_node("../BattleManager").available_units[i].unit_tag]).modulate = Color8(255, 255, 255)
					
	
		spawning = false
		meks_set = true
		turn_button.show()
		ai_button.show()
	
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

func on_tween_finished():
	get_node("../TileMap").get_child(1).stream = get_node("../TileMap").map_sfx[8]
	get_node("../TileMap").get_child(1).play()	

func end_turn():
	ai_button.hide()
	turn_button.hide()
	get_node("../TurnManager").cpu_turn_started.emit()
	ai_mode_bool = false

func end_user_turn():
	get_node("../TurnManager").cpu_turn_started.emit()

func get_random_numbers(from, to):
	var arr = []
	for i in range(from,to):
		arr.append(i)
	arr.shuffle()
	return arr

func ai_mode(toggled_on):
	#on_cpu_turn_started()
	on_user_ai_started()
	ai_button.hide()
	turn_button.hide()
	ai_button.hide()
	ai_mode_bool = true

func M1_picked(toggled_on):
	if toggled_on == true:
		user_keys.append("M1") 
		#picker.get_child(0).scale = Vector2(1.25, 1.25)
		picker.get_child(0).texture_normal = M1_thumb_norm
		teampick_count += 1
	else:
		for i in user_keys.size():
			if user_keys[i-1] == "M1":
				user_keys.remove_at(i)		
		picker.get_child(0).scale = Vector2(1, 1)	
		picker.get_child(0).texture_normal = M1_thumb_bw
		teampick_count -= 1
	
func M2_picked(toggled_on):
	if toggled_on == true:
		user_keys.append("M2") 
		#picker.get_child(1).scale = Vector2(1.25, 1.25)
		picker.get_child(1).texture_normal = M2_thumb_norm
		teampick_count += 1
	else:
		for i in user_keys.size():
			if user_keys[i-1] == "M2":
				user_keys.remove_at(i)			
		picker.get_child(1).scale = Vector2(1, 1)	
		picker.get_child(1).texture_normal = M2_thumb_bw
		teampick_count -= 1
	
func M3_picked(toggled_on):
	if toggled_on == true:
		user_keys.append("M3") 
		#picker.get_child(2).scale = Vector2(1.25, 1.25)
		picker.get_child(2).texture_normal = M3_thumb_norm
		teampick_count += 1
	else:
		for i in user_keys.size():
			if user_keys[i-1] == "M3":
				user_keys.remove_at(i)			
		picker.get_child(2).scale = Vector2(1, 1)
		picker.get_child(2).texture_normal = M3_thumb_bw
		teampick_count -= 1

func R1_picked(toggled_on):
	if toggled_on == true:
		user_keys.append("R1") 
		#picker.get_child(3).scale = Vector2(1.25, 1.25)
		picker.get_child(3).texture_normal = R1_thumb_norm
		teampick_count += 1
	else:
		for i in user_keys.size():
			if user_keys[i-1] == "R1":
				user_keys.remove_at(i)			 
		picker.get_child(3).scale = Vector2(1, 1)
		picker.get_child(3).texture_normal = R1_thumb_bw
		teampick_count -= 1
		
func R2_picked(toggled_on):
	if toggled_on == true:
		user_keys.append("R2") 
		#picker.get_child(4).scale = Vector2(1.25, 1.25)
		picker.get_child(4).texture_normal = R2_thumb_norm
		teampick_count += 1
	else:
		for i in user_keys.size():
			if user_keys[i-1] == "R2":
				user_keys.remove_at(i)			
		picker.get_child(4).scale = Vector2(1, 1)
		picker.get_child(4).texture_normal = R2_thumb_bw	
		teampick_count -= 1	

func R3_picked(toggled_on):
	if toggled_on == true:
		user_keys.append("R3") 
		#picker.get_child(5).scale = Vector2(1.25, 1.25)
		picker.get_child(5).texture_normal = R3_thumb_norm
		teampick_count += 1
	else:
		for i in user_keys.size():
			if user_keys[i-1] == "R3":
				user_keys.remove_at(i)			
		picker.get_child(5).scale = Vector2(1, 1)	
		picker.get_child(5).texture_normal = R3_thumb_bw
		teampick_count -= 1

func R4_picked(toggled_on):
	if toggled_on == true:
		user_keys.append("R4") 
		#picker.get_child(6).scale = Vector2(1.25, 1.25)
		picker.get_child(6).texture_normal = R4_thumb_norm
		teampick_count += 1
	else:
		for i in user_keys.size():
			if user_keys[i-1] == "R4":
				user_keys.remove_at(i)			
		picker.get_child(6).scale = Vector2(1, 1)
		picker.get_child(6).texture_normal = R4_thumb_bw
		teampick_count -= 1

func S1_picked(toggled_on):
	if toggled_on == true:
		user_keys.append("S1") 
		#picker.get_child(7).scale = Vector2(1.25, 1.25)
		picker.get_child(7).texture_normal = S1_thumb_norm
		teampick_count += 1
	else:
		for i in user_keys.size():
			if user_keys[i-1] == "S1":
				user_keys.remove_at(i)			
		picker.get_child(7).scale = Vector2(1, 1)
		picker.get_child(7).texture_normal = S1_thumb_bw
		teampick_count -= 1
		
func S2_picked(toggled_on):
	if toggled_on == true:
		user_keys.append("S2") 
		#picker.get_child(8).scale = Vector2(1.25, 1.25)
		picker.get_child(8).texture_normal = S2_thumb_norm
		teampick_count += 1
	else:
		for i in user_keys.size():
			if user_keys[i-1] == "S2":
				user_keys.remove_at(i)			
		picker.get_child(8).scale = Vector2(1, 1)	
		picker.get_child(8).texture_normal = S2_thumb_bw
		teampick_count -= 1
		
func S3_picked(toggled_on):
	if toggled_on == true:
		user_keys.append("S3") 
		#picker.get_child(9).scale = Vector2(1.25, 1.25)
		picker.get_child(9).texture_normal = S3_thumb_norm
		teampick_count += 1
	else:
		for i in user_keys.size():
			if user_keys[i-1] == "S3":
				user_keys.remove_at(i)			
		picker.get_child(9).scale = Vector2(1, 1)	
		picker.get_child(9).texture_normal = S3_thumb_bw
		teampick_count -= 1

func spawn_again():
	spawning = true
	for i in inactive_total_cpu.size():
		get_node("../BattleManager").inactive_total_cpu[i].get_child(0).modulate = Color8(255, 110, 255)
		get_node("../BattleManager").inactive_total_cpu[i].xp += 100
		get_node("../BattleManager").inactive_total_cpu[i].add_to_group("CPU Active")
		get_node("../BattleManager").inactive_total_cpu[i].unit_status = "Active"
		get_node("../BattleManager").inactive_total_cpu[i].show()
		get_node("../BattleManager").inactive_total_cpu[i].only_once = true

		# Find open tiles	
		for k in 16:
			for j in 16:
				if get_node("../TileMap").astar_grid.is_point_solid(Vector2i(k,j)) == false:			
					open_tiles.append(Vector2i(k,j))
			
		var new_position = get_node("../TileMap").map_to_local(open_tiles[random[i]]) + Vector2(0,0) / 2
		get_node("../BattleManager").inactive_total_cpu[i].position = Vector2(new_position.x, new_position.y-500)
		var tween: Tween = create_tween()
		tween.tween_property(get_node("../BattleManager").inactive_total_cpu[i], "position", new_position, 1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)	
		tween.connect("finished", on_tween_finished)
		await get_tree().create_timer(0.5).timeout		
	
	for node in get_tree().get_nodes_in_group("CPU Inactive"):
		node.remove_from_group("CPU Inactive")	

	for i in available_units.size():
		if available_units[i].unit_team == 1:
			available_units[i].xp += 100
			var tween: Tween = create_tween()
			tween.tween_property(get_node("../BattleManager").available_units[i], "modulate:v", 1, 0.50).from(5)	
		
	await get_tree().create_timer(1).timeout
	spawnagain_button.hide()
	on_cpu_turn_started()	
	spawning = false



