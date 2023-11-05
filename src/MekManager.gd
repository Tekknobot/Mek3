extends Area2D

var last_position: Vector2
var this_position: Vector2

@export var unit_name: String
@export var unit_team: int
@export var unit_num: int
@export var unit_type: String
@export var unit_range: int
@export var direction = Vector2.LEFT
@export var unit_min: int = 5
@export var unit_max: int = 5
@export var unit_portrait: Texture
@export var mek_portrait: Texture
@export var unit_level: int = 1
@export var unit_attack: int = 1
@export var unit_defence: int = 1

@export var unit_status: String = "Active"

@export var progressbar: ProgressBar

var flag_coroutine = false

@export var only_once : bool = true
var audio_flag = true

var hovered_unit: int

var xp = 0 
var level = 1 
var xp_requirements = 5

@export var mek_sfx: Array[AudioStream]

var unique_used = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):	
	# Face towards moving direction
	last_position = this_position
	this_position = self.position
	
	if this_position.x > last_position.x:
		scale.x = -1
		direction = Vector2.RIGHT
		#print("Facing RIGHT")
	if this_position.x < last_position.x:
		scale.x = 1	
		direction = Vector2.LEFT
		#print("Facing LEFT")
		
	var mouse_pos = get_global_mouse_position()
	var mouse_local_pos = get_node("../TileMap").local_to_map(mouse_pos)
	var tile_pos = get_node("../TileMap").local_to_map(self.position)	
	
	#Mouse hover
	if flag_coroutine == false:
		await get_tree().create_timer(0.1).timeout
		flag_coroutine = true

	if tile_pos == mouse_local_pos and self.unit_team == 1:
		self.get_child(0).set_use_parent_material(false)
		if !get_node("../TileMap").get_child(1).is_playing() and audio_flag:
			audio_flag = false
			get_node("../Control").show()
			get_node("../TileMap").get_child(1).stream = get_node("../TileMap").map_sfx[6]
			get_node("../TileMap").get_child(1).play()	
			get_node("../Control").get_child(3).texture = self.unit_portrait
			get_node("../Control").get_child(4).text = unit_name
			get_node("../Control").get_child(5).text = "LV. " + str(unit_level)
			get_node("../Control").get_child(6).text = "HP " + str(unit_min)
			get_node("../Control").get_child(7).text = "ATK " + str(unit_attack)
			get_node("../Control").get_child(8).text = "DEF " + str(unit_defence)
			get_node("../Control").get_child(9).value = self.unit_min
			get_node("../Control").get_child(10).set_value(xp)
			get_node("../Control").get_child(10).max_value = self.xp_requirements			
			get_node("../Control").get_child(13).texture = self.mek_portrait
			get_node("../Control").get_child(13).modulate = Color8(255, 255, 255)
			hovered_unit = self.unit_num
			if self.unique_used == false:
				get_node("../Control").get_child(17).show()
			else:
				get_node("../Control").get_child(17).hide()
			
	else:
		audio_flag = true
		self.get_child(0).set_use_parent_material(true)

	if tile_pos == mouse_local_pos and self.unit_team == 2:
		audio_flag = false	
		get_node("../Control").show()
		get_node("../Control").get_child(3).texture = self.unit_portrait
		get_node("../Control").get_child(4).text = unit_name
		get_node("../Control").get_child(5).text = "LV. " + str(unit_level)
		get_node("../Control").get_child(6).text = "HP " + str(unit_min)
		get_node("../Control").get_child(7).text = "ATK " + str(unit_attack)
		get_node("../Control").get_child(8).text = "DEF " + str(unit_defence)
		get_node("../Control").get_child(9).value = self.unit_min
		get_node("../Control").get_child(10).set_value(xp)			
		get_node("../Control").get_child(10).max_value = self.xp_requirements		
		get_node("../Control").get_child(13).texture = self.mek_portrait
		get_node("../Control").get_child(13).modulate = Color8(255, 110, 255)
		get_node("../Control").get_child(17).show()
		#hovered_unit = unit_num
		
	
	if self.position == Vector2(1000,1000):
		return
	else:
		var unit_global_pos = self.position
		var unit_pos = get_node("../TileMap").local_to_map(unit_global_pos)
		get_node("../TileMap").astar_grid.set_point_solid(unit_pos, true)

	if self.position == Vector2(1000,1000):
		return
	else:		
		var unit_global_pos = self.position
		var unit_pos = get_node("../TileMap").local_to_map(unit_global_pos)
		get_node("../TileMap").astar_grid.set_point_solid(unit_pos, true)

		
	# Z Index Layering
	if self.unit_team == 1:
		get_node("../TileMap").unitsCoord_1[unit_num] = tile_pos
		get_node("../BattleManager").team_1[unit_num].z_index = tile_pos.x + tile_pos.y
	
	if self.unit_team == 2:
		get_node("../TileMap").unitsCoord_2[unit_num] = tile_pos
		get_node("../BattleManager").team_2[unit_num].z_index = tile_pos.x + tile_pos.y
	
	#Structure collisions			
	for i in get_node("../TileMap").totaltiles:
		var unit_center_pos = get_node("../TileMap").local_to_map(self.position)
		if unit_center_pos == get_node("../TileMap").structureCoord[i]:
			var unit_cell_center_pos = get_node("../TileMap").map_to_local(unit_center_pos) + Vector2(0,0) / 2			
			for j in get_node("../TileMap").structureArray.size():
				if get_node("../TileMap").structureArray[j].position == unit_cell_center_pos:
					unit_min = 0	
					get_node("../TileMap").structureArray[j].get_child(0).play("demolished")	
			
	# Check for Team Mek collisions	
	for i in get_node("../BattleManager").team_1.size():
		var unit_center_pos = get_node("../TileMap").local_to_map(self.position)
		var unit_pos_1 = get_node("../TileMap").local_to_map(get_node("../BattleManager").team_1[i].position)
		if unit_center_pos == unit_pos_1 and self.unit_num != get_node("../BattleManager").team_1[i].unit_num:
			unit_min = 0		
			
	for i in get_node("../BattleManager").team_2.size():
		var unit_center_pos = get_node("../TileMap").local_to_map(self.position)
		var unit_pos_2 = get_node("../TileMap").local_to_map(get_node("../BattleManager").team_2[i].position)		
		if unit_center_pos == unit_pos_2 and self.unit_num != get_node("../BattleManager").team_2[i].unit_num:
			unit_min = 0		

	# Check for Oppostie Team collisions	
	for i in get_node("../BattleManager").team_1.size():
		for j in get_node("../BattleManager").team_2.size():
			var unit_center_pos_1 = get_node("../TileMap").local_to_map(get_node("../BattleManager").team_1[i].position)
			var unit_center_pos_2 = get_node("../TileMap").local_to_map(get_node("../BattleManager").team_2[j].position)		
			if unit_center_pos_1 == unit_center_pos_2:
				get_node("../BattleManager").team_1[i].unit_min = 0		
				get_node("../BattleManager").team_2[j].unit_min = 0
																							
	#Check if bumped off map
	if self.unit_team == 2:
		var unit_center_pos = get_node("../BattleManager").team_2[unit_num].position
		var unit_pos = get_node("../TileMap").local_to_map(unit_center_pos)		
		if unit_pos.x < 0 or unit_pos.x > 15 or unit_pos.y < 0 or unit_pos.y > 15  and self.unit_team == 2:
			unit_min = 0	

	if self.unit_team == 1:
		var unit_center_pos = get_node("../BattleManager").team_1[unit_num].position
		var unit_pos = get_node("../TileMap").local_to_map(unit_center_pos)		
		if unit_pos.x < 0 or unit_pos.x > 15 or unit_pos.y < 0 or unit_pos.y > 15 and self.unit_team == 1:
			unit_min = 0
			
	#Check health
	if self.unit_min <= 0 and self.unit_team == 2 and only_once:
		only_once = false
		var unit_center_pos = get_node("../TileMap").local_to_map(get_node("../BattleManager").team_2[unit_num].position)		
		var unit_cell_center_pos = get_node("../TileMap").map_to_local(unit_center_pos) + Vector2(0,0) / 2
		var explosion = preload("res://prefab/vfx/explosion_area_2d.tscn")
		var explosion_instance = explosion.instantiate()
		var explosion_pos = get_node("../TileMap").map_to_local(unit_center_pos) + Vector2(0,0) / 2
		explosion_instance.set_name("explosion")
		get_parent().add_child(explosion_instance)
		explosion_instance.position = unit_cell_center_pos
		explosion_instance.z_index = explosion_pos.x + explosion_pos.y
		get_node("../BattleManager").team_2[unit_num].unit_status = "Inactive"
		get_node("../BattleManager").team_2[unit_num].add_to_group("Team 2: Inactive")
		get_node("../Camera2D").shake(0.5, 50, 8)
		#get_node("../BattleManager").team_2.pop_at(unit_num)
		#self.queue_free()
		get_node("../BattleManager").team_2[unit_num].hide()
		await get_tree().create_timer(0.7).timeout
		get_node("../BattleManager").team_2[unit_num].position = Vector2(1000,1000)	
		print(get_node("../BattleManager").team_2[unit_num].unit_name, " DESTROYED: Team ",  get_node("../BattleManager").team_2[unit_num].unit_team, " NO. " , get_node("../BattleManager").team_2[unit_num].unit_num)
				
		
	if self.unit_min <= 0 and self.unit_team == 1 and only_once: 
		only_once = false
		var unit_center_pos = get_node("../TileMap").local_to_map(get_node("../BattleManager").team_1[unit_num].position)		
		var unit_cell_center_pos = get_node("../TileMap").map_to_local(unit_center_pos) + Vector2(0,0) / 2
		var explosion = preload("res://prefab/vfx/explosion_area_2d.tscn")
		var explosion_instance = explosion.instantiate()
		var explosion_pos = get_node("../TileMap").map_to_local(unit_center_pos) + Vector2(0,0) / 2
		explosion_instance.set_name("explosion")
		get_node("../TileMap").add_child(explosion_instance)
		get_parent().add_child(explosion_instance)
		explosion_instance.position = unit_cell_center_pos
		explosion_instance.z_index = explosion_pos.x + explosion_pos.y
		get_node("../BattleManager").team_1[unit_num].unit_status = "Inactive"
		get_node("../BattleManager").team_1[unit_num].add_to_group("Team 1: Inactive")
		get_node("../Camera2D").shake(1, 50, 8)
		#get_node("../BattleManager").team_1.pop_at(unit_num)
		#self.queue_free()
		get_node("../BattleManager").team_1[unit_num].hide()
		await get_tree().create_timer(0.7).timeout
		get_node("../BattleManager").team_1[unit_num].position = Vector2(1000,1000)	
		print(get_node("../BattleManager").team_1[unit_num].unit_name, " DESTROYED: Team ",  get_node("../BattleManager").team_1[unit_num].unit_team, " NO. " , get_node("../BattleManager").team_1[unit_num].unit_num)
		
		
	if self.xp >= self.xp_requirements:
		self.xp_requirements += 5
		var tween: Tween = create_tween()
		tween.tween_property(self, "modulate:v", 1, 1.75).from(3.75)							
		
		get_child(5).stream = mek_sfx[0]
		get_child(5).play()			
		
		self.xp = 0
		self.unit_level += 1	
		self.unit_attack += 1
		self.unit_defence += 1	
		
		self.progressbar.max_value += 1
		self.unit_min = self.progressbar.max_value
		self.progressbar.set_value(self.unit_min)
		self.unit_max = self.progressbar.max_value	
		
		get_node("../Control").get_child(10).max_value = self.xp_requirements							

	if self.unit_min >= self.unit_max:
		self.unit_min = self.unit_max


