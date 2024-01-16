extends Control

@export var attack_button: Button
@export var special_button: Button
@export var health_button: Button
@export var unique_button: Button

@export var only_once : bool = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass		

func normal_attack(): 
	get_node("../TileMap").hovertile_type = 48
	return 48

func special_attack(): 
	get_node("../TileMap").hovertile_type = 24
	return 24
	
func health_action(): 
	only_once = true
	if get_node("../TileMap").moving == false:
		for i in get_node("../BattleManager").team_1.size():
			if get_node("../TileMap").hovered_unit == i:
				get_node("../BattleManager").team_1[i].unit_min += 1
				var tween: Tween = create_tween()
				tween.tween_property(get_node("../BattleManager").team_1[i], "modulate:v", 1, 0.75).from(3.75)
				get_node("../BattleManager").team_1[i].progressbar.set_value(get_node("../BattleManager").team_1[i].unit_min)	
				get_node("../BattleManager").team_1[i].get_child(5).stream = get_node("../BattleManager").team_1[i].mek_sfx[1]
				get_node("../BattleManager").team_1[i].get_child(5).play()
			if only_once:
				only_once = false
				get_node("../TurnManager").advance_turn() #
				
func unique_attack(): 
	if only_once:
		only_once = false
		for i in get_node("../BattleManager").team_1.size():
			#Tank
			if get_node("../BattleManager").team_1[i].unit_name == "Tank" and get_node("../TileMap").hovered_unit == i:
				var user_tile_pos = get_node("../TileMap").local_to_map(get_node("../BattleManager").team_1[i].position)
				var surrounding_cells = get_node("../TileMap").get_surrounding_cells(user_tile_pos)
				for j in surrounding_cells.size():
					var cell_center_pos = get_node("../TileMap").map_to_local(surrounding_cells[j]) + Vector2(0,0) / 2
					var explosion = preload("res://prefab/vfx/explosion_area_2d.tscn")
					var explosion_instance = explosion.instantiate()
					var explosion_pos = get_node("../TileMap").map_to_local(cell_center_pos) + Vector2(0,0) / 2
					explosion_instance.set_name("explosion")
					get_node("../TileMap").add_child(explosion_instance)
					get_parent().add_child(explosion_instance)
					explosion_instance.position = cell_center_pos
					explosion_instance.z_index = 1000
					for k in get_node("../BattleManager").team_2.size():
						if get_node("../BattleManager").team_2[k].position == cell_center_pos:
							get_node("../BattleManager").team_2[k].unit_min -= get_node("../BattleManager").team_1[i].unit_level
							get_node("../BattleManager").team_2[k].progressbar.set_value(get_node("../BattleManager").team_2[k].unit_min)
							var tween: Tween = create_tween()
							tween.tween_property(get_node("../BattleManager").team_2[k], "modulate:v", 1, 0.50).from(5)
							
					get_node("../BattleManager").team_1[i].get_child(0).play("attack")
					await get_tree().create_timer(0.5).timeout
				get_node("../BattleManager").team_1[i].xp += get_node("../BattleManager").team_1[i].unit_level
				get_node("../BattleManager").team_1[i].get_child(0).play("default")
				get_node("../BattleManager").team_1[i].unique_used = true
				get_node("../TurnManager").advance_turn()
			#Warheather
			if get_node("../BattleManager").team_1[i].unit_name == "Warheather" and get_node("../TileMap").hovered_unit == i:
				var user_tile_pos = get_node("../TileMap").local_to_map(get_node("../BattleManager").team_1[i].position)
				var surrounding_cells = get_node("../TileMap").get_surrounding_cells(user_tile_pos)
				for j in get_node("../BattleManager").team_2.size():
					var team2_unit = get_node("../TileMap").local_to_map(get_node("../BattleManager").team_2[j].position)
					var cell_center_pos = get_node("../TileMap").map_to_local(team2_unit) + Vector2(0,0) / 2
					var explosion = preload("res://prefab/vfx/explosion_area_2d.tscn")
					var explosion_instance = explosion.instantiate()
					var explosion_pos = get_node("../TileMap").map_to_local(cell_center_pos) + Vector2(0,0) / 2
					explosion_instance.set_name("explosion")
					get_node("../TileMap").add_child(explosion_instance)
					get_parent().add_child(explosion_instance)
					explosion_instance.position = cell_center_pos
					explosion_instance.z_index = 1000
					for k in get_node("../BattleManager").team_2.size():
						if get_node("../BattleManager").team_2[k].position == cell_center_pos:
							get_node("../BattleManager").team_2[k].unit_min -= get_node("../BattleManager").team_1[i].unit_level
							get_node("../BattleManager").team_2[k].progressbar.set_value(get_node("../BattleManager").team_2[k].unit_min)
							var tween: Tween = create_tween()
							tween.tween_property(get_node("../BattleManager").team_2[k], "modulate:v", 1, 0.50).from(5)
					
					get_node("../BattleManager").team_1[i].get_child(0).play("attack")		
					await get_tree().create_timer(0.5).timeout
				get_node("../BattleManager").team_1[i].xp += get_node("../BattleManager").team_1[i].unit_level
				get_node("../BattleManager").team_1[i].get_child(0).play("default")
				get_node("../BattleManager").team_1[i].unique_used = true
				get_node("../TurnManager").advance_turn()
			#Spiderbot
			if get_node("../BattleManager").team_1[i].unit_name == "Spiderbot" and get_node("../TileMap").hovered_unit == i:
				var user_tile_pos = get_node("../TileMap").local_to_map(get_node("../BattleManager").team_1[i].position)
				for j in 3:
					var cell_center_pos = get_node("../TileMap").map_to_local(Vector2i(user_tile_pos.x+j+1, user_tile_pos.y))+ Vector2(0,0) / 2
					var explosion = preload("res://prefab/vfx/explosion_area_2d.tscn")
					var explosion_instance = explosion.instantiate()
					var explosion_pos = get_node("../TileMap").map_to_local(cell_center_pos) + Vector2(0,0) / 2
					explosion_instance.set_name("explosion")
					get_node("../TileMap").add_child(explosion_instance)
					get_parent().add_child(explosion_instance)
					explosion_instance.position = cell_center_pos
					explosion_instance.z_index = 1000
					for k in get_node("../BattleManager").team_2.size():
						if get_node("../BattleManager").team_2[k].position == cell_center_pos:
							get_node("../BattleManager").team_2[k].unit_min -= get_node("../BattleManager").team_1[i].unit_level
							get_node("../BattleManager").team_2[k].progressbar.set_value(get_node("../BattleManager").team_2[k].unit_min)
							var tween: Tween = create_tween()
							tween.tween_property(get_node("../BattleManager").team_2[k], "modulate:v", 1, 0.50).from(5)
					
					get_node("../BattleManager").team_1[i].get_child(0).play("attack")					
					await get_tree().create_timer(0.5).timeout
				for j in 3:
					var cell_center_pos = get_node("../TileMap").map_to_local(Vector2i(user_tile_pos.x-j-1, user_tile_pos.y))+ Vector2(0,0) / 2
					var explosion = preload("res://prefab/vfx/explosion_area_2d.tscn")
					var explosion_instance = explosion.instantiate()
					var explosion_pos = get_node("../TileMap").map_to_local(cell_center_pos) + Vector2(0,0) / 2
					explosion_instance.set_name("explosion")
					get_node("../TileMap").add_child(explosion_instance)
					get_parent().add_child(explosion_instance)
					explosion_instance.position = cell_center_pos
					explosion_instance.z_index = 1000	
					for k in get_node("../BattleManager").team_2.size():
						if get_node("../BattleManager").team_2[k].position == cell_center_pos:
							get_node("../BattleManager").team_2[k].unit_min -= get_node("../BattleManager").team_1[i].unit_level
							get_node("../BattleManager").team_2[k].progressbar.set_value(get_node("../BattleManager").team_2[k].unit_min)
							var tween: Tween = create_tween()
							tween.tween_property(get_node("../BattleManager").team_2[k], "modulate:v", 1, 0.50).from(5)
					
					get_node("../BattleManager").team_1[i].get_child(0).play("attack")							
					await get_tree().create_timer(0.5).timeout
				for j in 3:
					var cell_center_pos = get_node("../TileMap").map_to_local(Vector2i(user_tile_pos.x, user_tile_pos.y+j+1))+ Vector2(0,0) / 2
					var explosion = preload("res://prefab/vfx/explosion_area_2d.tscn")
					var explosion_instance = explosion.instantiate()
					var explosion_pos = get_node("../TileMap").map_to_local(cell_center_pos) + Vector2(0,0) / 2
					explosion_instance.set_name("explosion")
					get_node("../TileMap").add_child(explosion_instance)
					get_parent().add_child(explosion_instance)
					explosion_instance.position = cell_center_pos
					explosion_instance.z_index = 1000	
					for k in get_node("../BattleManager").team_2.size():
						if get_node("../BattleManager").team_2[k].position == cell_center_pos:
							get_node("../BattleManager").team_2[k].unit_min -= get_node("../BattleManager").team_1[i].unit_level
							get_node("../BattleManager").team_2[k].progressbar.set_value(get_node("../BattleManager").team_2[k].unit_min)
							var tween: Tween = create_tween()
							tween.tween_property(get_node("../BattleManager").team_2[k], "modulate:v", 1, 0.50).from(5)
					
					get_node("../BattleManager").team_1[i].get_child(0).play("attack")							
					await get_tree().create_timer(0.5).timeout
				for j in 3:
					var cell_center_pos = get_node("../TileMap").map_to_local(Vector2i(user_tile_pos.x, user_tile_pos.y-j-1))+ Vector2(0,0) / 2
					var explosion = preload("res://prefab/vfx/explosion_area_2d.tscn")
					var explosion_instance = explosion.instantiate()
					var explosion_pos = get_node("../TileMap").map_to_local(cell_center_pos) + Vector2(0,0) / 2
					explosion_instance.set_name("explosion")
					get_node("../TileMap").add_child(explosion_instance)
					get_parent().add_child(explosion_instance)
					explosion_instance.position = cell_center_pos
					explosion_instance.z_index = 1000	
					for k in get_node("../BattleManager").team_2.size():
						if get_node("../BattleManager").team_2[k].position == cell_center_pos:
							get_node("../BattleManager").team_2[k].unit_min -= get_node("../BattleManager").team_1[i].unit_level
							get_node("../BattleManager").team_2[k].progressbar.set_value(get_node("../BattleManager").team_2[k].unit_min)
							var tween: Tween = create_tween()
							tween.tween_property(get_node("../BattleManager").team_2[k], "modulate:v", 1, 0.50).from(5)
					
					get_node("../BattleManager").team_1[i].get_child(0).play("attack")					
					await get_tree().create_timer(0.5).timeout
				get_node("../BattleManager").team_1[i].xp += get_node("../BattleManager").team_1[i].unit_level		
				get_node("../BattleManager").team_1[i].get_child(0).play("default")
				get_node("../BattleManager").team_1[i].unique_used = true							
				get_node("../TurnManager").advance_turn()			
			#Angie
			if get_node("../BattleManager").team_1[i].unit_name == "Angie" and get_node("../TileMap").hovered_unit == i:
				var user_tile_pos = get_node("../TileMap").local_to_map(get_node("../BattleManager").team_1[i].position)
				var surrounding_cells = get_node("../TileMap").get_surrounding_cells(user_tile_pos)
				for j in surrounding_cells.size():
					var cell_center_pos = get_node("../TileMap").map_to_local(surrounding_cells[j]) + Vector2(0,0) / 2
					var explosion = preload("res://prefab/vfx/explosion_area_2d.tscn")
					var explosion_instance = explosion.instantiate()
					var explosion_pos = get_node("../TileMap").map_to_local(cell_center_pos) + Vector2(0,0) / 2
					explosion_instance.set_name("explosion")
					get_node("../TileMap").add_child(explosion_instance)
					get_parent().add_child(explosion_instance)
					explosion_instance.position = cell_center_pos
					explosion_instance.z_index = 1000
					for k in get_node("../BattleManager").team_2.size():
						if get_node("../BattleManager").team_2[k].position == cell_center_pos:
							get_node("../BattleManager").team_2[k].unit_min -= get_node("../BattleManager").team_1[i].unit_level
							get_node("../BattleManager").team_2[k].progressbar.set_value(get_node("../BattleManager").team_2[k].unit_min)
							var tween: Tween = create_tween()
							tween.tween_property(get_node("../BattleManager").team_2[k], "modulate:v", 1, 0.50).from(5)
							
					get_node("../BattleManager").team_1[i].get_child(0).play("attack")
					await get_tree().create_timer(0.5).timeout
				get_node("../BattleManager").team_1[i].xp += get_node("../BattleManager").team_1[i].unit_level	
				get_node("../BattleManager").team_1[i].get_child(0).play("default")
				get_node("../BattleManager").team_1[i].unique_used = true
				get_node("../TurnManager").advance_turn()
			#Russ
			if get_node("../BattleManager").team_1[i].unit_name == "Russ" and get_node("../TileMap").hovered_unit == i:
				var user_tile_pos = get_node("../TileMap").local_to_map(get_node("../BattleManager").team_1[i].position)
				var surrounding_cells = get_node("../TileMap").get_surrounding_cells(user_tile_pos)
				for j in get_node("../BattleManager").team_2.size():
					var team2_unit = get_node("../TileMap").local_to_map(get_node("../BattleManager").team_2[j].position)
					var cell_center_pos = get_node("../TileMap").map_to_local(team2_unit) + Vector2(0,0) / 2
					var explosion = preload("res://prefab/vfx/explosion_area_2d.tscn")
					var explosion_instance = explosion.instantiate()
					var explosion_pos = get_node("../TileMap").map_to_local(cell_center_pos) + Vector2(0,0) / 2
					explosion_instance.set_name("explosion")
					get_node("../TileMap").add_child(explosion_instance)
					get_parent().add_child(explosion_instance)
					explosion_instance.position = cell_center_pos
					explosion_instance.z_index = 1000
					for k in get_node("../BattleManager").team_2.size():
						if get_node("../BattleManager").team_2[k].position == cell_center_pos:
							get_node("../BattleManager").team_2[k].unit_min -= get_node("../BattleManager").team_1[i].unit_level
							get_node("../BattleManager").team_2[k].progressbar.set_value(get_node("../BattleManager").team_2[k].unit_min)
							var tween: Tween = create_tween()
							tween.tween_property(get_node("../BattleManager").team_2[k], "modulate:v", 1, 0.50).from(5)
					
					get_node("../BattleManager").team_1[i].get_child(0).play("attack")		
					await get_tree().create_timer(0.5).timeout
				get_node("../BattleManager").team_1[i].xp += get_node("../BattleManager").team_1[i].unit_level
				get_node("../BattleManager").team_1[i].get_child(0).play("default")
				get_node("../BattleManager").team_1[i].unique_used = true
				get_node("../TurnManager").advance_turn()
			#Pantherbot
			if get_node("../BattleManager").team_1[i].unit_name == "Pantherbot" and get_node("../TileMap").hovered_unit == i:
				var user_tile_pos = get_node("../TileMap").local_to_map(get_node("../BattleManager").team_1[i].position)
				for j in 3:
					var cell_center_pos = get_node("../TileMap").map_to_local(Vector2i(user_tile_pos.x+j+1, user_tile_pos.y))+ Vector2(0,0) / 2
					var explosion = preload("res://prefab/vfx/explosion_area_2d.tscn")
					var explosion_instance = explosion.instantiate()
					var explosion_pos = get_node("../TileMap").map_to_local(cell_center_pos) + Vector2(0,0) / 2
					explosion_instance.set_name("explosion")
					get_node("../TileMap").add_child(explosion_instance)
					get_parent().add_child(explosion_instance)
					explosion_instance.position = cell_center_pos
					explosion_instance.z_index = 1000
					for k in get_node("../BattleManager").team_2.size():
						if get_node("../BattleManager").team_2[k].position == cell_center_pos:
							get_node("../BattleManager").team_2[k].unit_min -= get_node("../BattleManager").team_1[i].unit_level
							get_node("../BattleManager").team_2[k].progressbar.set_value(get_node("../BattleManager").team_2[k].unit_min)
							var tween: Tween = create_tween()
							tween.tween_property(get_node("../BattleManager").team_2[k], "modulate:v", 1, 0.50).from(5)
					
					get_node("../BattleManager").team_1[i].get_child(0).play("attack")					
					await get_tree().create_timer(0.5).timeout
				for j in 3:
					var cell_center_pos = get_node("../TileMap").map_to_local(Vector2i(user_tile_pos.x-j-1, user_tile_pos.y))+ Vector2(0,0) / 2
					var explosion = preload("res://prefab/vfx/explosion_area_2d.tscn")
					var explosion_instance = explosion.instantiate()
					var explosion_pos = get_node("../TileMap").map_to_local(cell_center_pos) + Vector2(0,0) / 2
					explosion_instance.set_name("explosion")
					get_node("../TileMap").add_child(explosion_instance)
					get_parent().add_child(explosion_instance)
					explosion_instance.position = cell_center_pos
					explosion_instance.z_index = 1000	
					for k in get_node("../BattleManager").team_2.size():
						if get_node("../BattleManager").team_2[k].position == cell_center_pos:
							get_node("../BattleManager").team_2[k].unit_min -= get_node("../BattleManager").team_1[i].unit_level
							get_node("../BattleManager").team_2[k].progressbar.set_value(get_node("../BattleManager").team_2[k].unit_min)
							var tween: Tween = create_tween()
							tween.tween_property(get_node("../BattleManager").team_2[k], "modulate:v", 1, 0.50).from(5)
					
					get_node("../BattleManager").team_1[i].get_child(0).play("attack")							
					await get_tree().create_timer(0.1).timeout
				for j in 3:
					var cell_center_pos = get_node("../TileMap").map_to_local(Vector2i(user_tile_pos.x, user_tile_pos.y+j+1))+ Vector2(0,0) / 2
					var explosion = preload("res://prefab/vfx/explosion_area_2d.tscn")
					var explosion_instance = explosion.instantiate()
					var explosion_pos = get_node("../TileMap").map_to_local(cell_center_pos) + Vector2(0,0) / 2
					explosion_instance.set_name("explosion")
					get_node("../TileMap").add_child(explosion_instance)
					get_parent().add_child(explosion_instance)
					explosion_instance.position = cell_center_pos
					explosion_instance.z_index = 1000	
					for k in get_node("../BattleManager").team_2.size():
						if get_node("../BattleManager").team_2[k].position == cell_center_pos:
							get_node("../BattleManager").team_2[k].unit_min -= get_node("../BattleManager").team_1[i].unit_level
							get_node("../BattleManager").team_2[k].progressbar.set_value(get_node("../BattleManager").team_2[k].unit_min)
							var tween: Tween = create_tween()
							tween.tween_property(get_node("../BattleManager").team_2[k], "modulate:v", 1, 0.50).from(5)
					
					get_node("../BattleManager").team_1[i].get_child(0).play("attack")							
					await get_tree().create_timer(0.1).timeout
				for j in 3:
					var cell_center_pos = get_node("../TileMap").map_to_local(Vector2i(user_tile_pos.x, user_tile_pos.y-j-1))+ Vector2(0,0) / 2
					var explosion = preload("res://prefab/vfx/explosion_area_2d.tscn")
					var explosion_instance = explosion.instantiate()
					var explosion_pos = get_node("../TileMap").map_to_local(cell_center_pos) + Vector2(0,0) / 2
					explosion_instance.set_name("explosion")
					get_node("../TileMap").add_child(explosion_instance)
					get_parent().add_child(explosion_instance)
					explosion_instance.position = cell_center_pos
					explosion_instance.z_index = 1000	
					for k in get_node("../BattleManager").team_2.size():
						if get_node("../BattleManager").team_2[k].position == cell_center_pos:
							get_node("../BattleManager").team_2[k].unit_min -= get_node("../BattleManager").team_1[i].unit_level
							get_node("../BattleManager").team_2[k].progressbar.set_value(get_node("../BattleManager").team_2[k].unit_min)
							var tween: Tween = create_tween()
							tween.tween_property(get_node("../BattleManager").team_2[k], "modulate:v", 1, 0.50).from(5)
					
					get_node("../BattleManager").team_1[i].get_child(0).play("attack")					
					await get_tree().create_timer(0.1).timeout
				get_node("../BattleManager").team_1[i].xp += get_node("../BattleManager").team_1[i].unit_level		
				get_node("../BattleManager").team_1[i].get_child(0).play("default")
				get_node("../BattleManager").team_1[i].unique_used = true							
				get_node("../TurnManager").advance_turn()			
			#Marvette
			if get_node("../BattleManager").team_1[i].unit_name == "Marvette" and get_node("../TileMap").hovered_unit == i:
				var user_tile_pos = get_node("../TileMap").local_to_map(get_node("../BattleManager").team_1[i].position)
				var surrounding_cells = get_node("../TileMap").get_surrounding_cells(user_tile_pos)
				for j in surrounding_cells.size():
					var cell_center_pos = get_node("../TileMap").map_to_local(surrounding_cells[j]) + Vector2(0,0) / 2
					var explosion = preload("res://prefab/vfx/explosion_area_2d.tscn")
					var explosion_instance = explosion.instantiate()
					var explosion_pos = get_node("../TileMap").map_to_local(cell_center_pos) + Vector2(0,0) / 2
					explosion_instance.set_name("explosion")
					get_node("../TileMap").add_child(explosion_instance)
					get_parent().add_child(explosion_instance)
					explosion_instance.position = cell_center_pos
					explosion_instance.z_index = 1000
					for k in get_node("../BattleManager").team_2.size():
						if get_node("../BattleManager").team_2[k].position == cell_center_pos:
							get_node("../BattleManager").team_2[k].unit_min -= get_node("../BattleManager").team_1[i].unit_level
							get_node("../BattleManager").team_2[k].progressbar.set_value(get_node("../BattleManager").team_2[k].unit_min)
							var tween: Tween = create_tween()
							tween.tween_property(get_node("../BattleManager").team_2[k], "modulate:v", 1, 0.50).from(5)
							
					get_node("../BattleManager").team_1[i].get_child(0).play("attack")
					await get_tree().create_timer(0.5).timeout
				get_node("../BattleManager").team_1[i].xp += get_node("../BattleManager").team_1[i].unit_level
				get_node("../BattleManager").team_1[i].get_child(0).play("default")
				get_node("../BattleManager").team_1[i].unique_used = true
				get_node("../TurnManager").advance_turn()
			#Rogersan
			if get_node("../BattleManager").team_1[i].unit_name == "Rogersan" and get_node("../TileMap").hovered_unit == i:
				var user_tile_pos = get_node("../TileMap").local_to_map(get_node("../BattleManager").team_1[i].position)
				var surrounding_cells = get_node("../TileMap").get_surrounding_cells(user_tile_pos)
				for j in get_node("../BattleManager").team_2.size():
					var team2_unit = get_node("../TileMap").local_to_map(get_node("../BattleManager").team_2[j].position)
					var cell_center_pos = get_node("../TileMap").map_to_local(team2_unit) + Vector2(0,0) / 2
					var explosion = preload("res://prefab/vfx/explosion_area_2d.tscn")
					var explosion_instance = explosion.instantiate()
					var explosion_pos = get_node("../TileMap").map_to_local(cell_center_pos) + Vector2(0,0) / 2
					explosion_instance.set_name("explosion")
					get_node("../TileMap").add_child(explosion_instance)
					get_parent().add_child(explosion_instance)
					explosion_instance.position = cell_center_pos
					explosion_instance.z_index = 1000
					for k in get_node("../BattleManager").team_2.size():
						if get_node("../BattleManager").team_2[k].position == cell_center_pos:
							get_node("../BattleManager").team_2[k].unit_min -= get_node("../BattleManager").team_1[i].unit_level
							get_node("../BattleManager").team_2[k].progressbar.set_value(get_node("../BattleManager").team_2[k].unit_min)
							var tween: Tween = create_tween()
							tween.tween_property(get_node("../BattleManager").team_2[k], "modulate:v", 1, 0.50).from(5)
					
					get_node("../BattleManager").team_1[i].get_child(0).play("attack")		
					await get_tree().create_timer(0.5).timeout
				get_node("../BattleManager").team_1[i].xp += get_node("../BattleManager").team_1[i].unit_level
				get_node("../BattleManager").team_1[i].get_child(0).play("default")
				get_node("../BattleManager").team_1[i].unique_used = true
				get_node("../TurnManager").advance_turn()
			#Dutch				
			if get_node("../BattleManager").team_1[i].unit_name == "Dutch" and get_node("../TileMap").hovered_unit == i:
				var user_tile_pos = get_node("../TileMap").local_to_map(get_node("../BattleManager").team_1[i].position)
				for j in 3:
					var cell_center_pos = get_node("../TileMap").map_to_local(Vector2i(user_tile_pos.x+j+1, user_tile_pos.y))+ Vector2(0,0) / 2
					var explosion = preload("res://prefab/vfx/explosion_area_2d.tscn")
					var explosion_instance = explosion.instantiate()
					var explosion_pos = get_node("../TileMap").map_to_local(cell_center_pos) + Vector2(0,0) / 2
					explosion_instance.set_name("explosion")
					get_node("../TileMap").add_child(explosion_instance)
					get_parent().add_child(explosion_instance)
					explosion_instance.position = cell_center_pos
					explosion_instance.z_index = 1000
					for k in get_node("../BattleManager").team_2.size():
						if get_node("../BattleManager").team_2[k].position == cell_center_pos:
							get_node("../BattleManager").team_2[k].unit_min -= get_node("../BattleManager").team_1[i].unit_level
							get_node("../BattleManager").team_2[k].progressbar.set_value(get_node("../BattleManager").team_2[k].unit_min)
							var tween: Tween = create_tween()
							tween.tween_property(get_node("../BattleManager").team_2[k], "modulate:v", 1, 0.50).from(5)
					
					get_node("../BattleManager").team_1[i].get_child(0).play("attack")					
					await get_tree().create_timer(0.5).timeout
				for j in 3:
					var cell_center_pos = get_node("../TileMap").map_to_local(Vector2i(user_tile_pos.x-j-1, user_tile_pos.y))+ Vector2(0,0) / 2
					var explosion = preload("res://prefab/vfx/explosion_area_2d.tscn")
					var explosion_instance = explosion.instantiate()
					var explosion_pos = get_node("../TileMap").map_to_local(cell_center_pos) + Vector2(0,0) / 2
					explosion_instance.set_name("explosion")
					get_node("../TileMap").add_child(explosion_instance)
					get_parent().add_child(explosion_instance)
					explosion_instance.position = cell_center_pos
					explosion_instance.z_index = 1000	
					for k in get_node("../BattleManager").team_2.size():
						if get_node("../BattleManager").team_2[k].position == cell_center_pos:
							get_node("../BattleManager").team_2[k].unit_min -= get_node("../BattleManager").team_1[i].unit_level
							get_node("../BattleManager").team_2[k].progressbar.set_value(get_node("../BattleManager").team_2[k].unit_min)
							var tween: Tween = create_tween()
							tween.tween_property(get_node("../BattleManager").team_2[k], "modulate:v", 1, 0.50).from(5)
					
					get_node("../BattleManager").team_1[i].get_child(0).play("attack")							
					await get_tree().create_timer(0.5).timeout
				for j in 3:
					var cell_center_pos = get_node("../TileMap").map_to_local(Vector2i(user_tile_pos.x, user_tile_pos.y+j+1))+ Vector2(0,0) / 2
					var explosion = preload("res://prefab/vfx/explosion_area_2d.tscn")
					var explosion_instance = explosion.instantiate()
					var explosion_pos = get_node("../TileMap").map_to_local(cell_center_pos) + Vector2(0,0) / 2
					explosion_instance.set_name("explosion")
					get_node("../TileMap").add_child(explosion_instance)
					get_parent().add_child(explosion_instance)
					explosion_instance.position = cell_center_pos
					explosion_instance.z_index = 1000	
					for k in get_node("../BattleManager").team_2.size():
						if get_node("../BattleManager").team_2[k].position == cell_center_pos:
							get_node("../BattleManager").team_2[k].unit_min -= get_node("../BattleManager").team_1[i].unit_level
							get_node("../BattleManager").team_2[k].progressbar.set_value(get_node("../BattleManager").team_2[k].unit_min)
							var tween: Tween = create_tween()
							tween.tween_property(get_node("../BattleManager").team_2[k], "modulate:v", 1, 0.50).from(5)
					
					get_node("../BattleManager").team_1[i].get_child(0).play("attack")							
					await get_tree().create_timer(0.5).timeout
				for j in 3:
					var cell_center_pos = get_node("../TileMap").map_to_local(Vector2i(user_tile_pos.x, user_tile_pos.y-j-1))+ Vector2(0,0) / 2
					var explosion = preload("res://prefab/vfx/explosion_area_2d.tscn")
					var explosion_instance = explosion.instantiate()
					var explosion_pos = get_node("../TileMap").map_to_local(cell_center_pos) + Vector2(0,0) / 2
					explosion_instance.set_name("explosion")
					get_node("../TileMap").add_child(explosion_instance)
					get_parent().add_child(explosion_instance)
					explosion_instance.position = cell_center_pos
					explosion_instance.z_index = 1000	
					for k in get_node("../BattleManager").team_2.size():
						if get_node("../BattleManager").team_2[k].position == cell_center_pos:
							get_node("../BattleManager").team_2[k].unit_min -= get_node("../BattleManager").team_1[i].unit_level
							get_node("../BattleManager").team_2[k].progressbar.set_value(get_node("../BattleManager").team_2[k].unit_min)
							var tween: Tween = create_tween()
							tween.tween_property(get_node("../BattleManager").team_2[k], "modulate:v", 1, 0.50).from(5)
					
					get_node("../BattleManager").team_1[i].get_child(0).play("attack")					
					await get_tree().create_timer(0.5).timeout
				get_node("../BattleManager").team_1[i].xp += get_node("../BattleManager").team_1[i].unit_level		
				get_node("../BattleManager").team_1[i].get_child(0).play("default")
				get_node("../BattleManager").team_1[i].unique_used = true							
				get_node("../TurnManager").advance_turn()			
			#Slash
			if get_node("../BattleManager").team_1[i].unit_name == "Slash" and get_node("../TileMap").hovered_unit == i:
				var user_tile_pos = get_node("../TileMap").local_to_map(get_node("../BattleManager").team_1[i].position)
				var surrounding_cells = get_node("../TileMap").get_surrounding_cells(user_tile_pos)
				for j in surrounding_cells.size():
					var cell_center_pos = get_node("../TileMap").map_to_local(surrounding_cells[j]) + Vector2(0,0) / 2
					var explosion = preload("res://prefab/vfx/explosion_area_2d.tscn")
					var explosion_instance = explosion.instantiate()
					var explosion_pos = get_node("../TileMap").map_to_local(cell_center_pos) + Vector2(0,0) / 2
					explosion_instance.set_name("explosion")
					get_node("../TileMap").add_child(explosion_instance)
					get_parent().add_child(explosion_instance)
					explosion_instance.position = cell_center_pos
					explosion_instance.z_index = 1000
					for k in get_node("../BattleManager").team_2.size():
						if get_node("../BattleManager").team_2[k].position == cell_center_pos:
							get_node("../BattleManager").team_2[k].unit_min -= get_node("../BattleManager").team_1[i].unit_level
							get_node("../BattleManager").team_2[k].progressbar.set_value(get_node("../BattleManager").team_2[k].unit_min)
							var tween: Tween = create_tween()
							tween.tween_property(get_node("../BattleManager").team_2[k], "modulate:v", 1, 0.50).from(5)
							
					get_node("../BattleManager").team_1[i].get_child(0).play("attack")
					await get_tree().create_timer(0.5).timeout
				get_node("../BattleManager").team_1[i].xp += get_node("../BattleManager").team_1[i].unit_level	
				get_node("../BattleManager").team_1[i].get_child(0).play("default")
				get_node("../BattleManager").team_1[i].unique_used = true
				get_node("../TurnManager").advance_turn()
					
		get_node("../Control").get_child(17).hide()
