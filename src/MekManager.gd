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
@export var unit_defence: int = 0
@export var unit_movement: int = 3
@export var unit_tag: String

@export var unit_status: String = "Active"

@export var progressbar: ProgressBar
@export var Levelprogressbar: ProgressBar

var flag_coroutine = false

@export var only_once : bool = true

var audio_flag = true
var audio_flag_2 = true

var hovered_unit: int

var xp = 0 
var level = 1 
var xp_requirements = 3

@export var mek_sfx: Array[AudioStream]

var structures: Array[Area2D]
var buildings = []
var towers = []
var stadiums = []
var districts = []

var meks = []

var moved = false
var attacked = false

var mek_coord: Vector2i

var pos : Vector2
var old_pos : Vector2
var moving : bool

var sub = 0
var tile_id = 0
var can_attack = false
var in_water = false
var tween

# Called when the node enters the scene tree for the first time.
func _ready():
	buildings = get_tree().get_nodes_in_group("buildings")
	towers = get_tree().get_nodes_in_group("towers")
	stadiums = get_tree().get_nodes_in_group("stadiums")
	districts = get_tree().get_nodes_in_group("districts")
	
	meks = get_tree().get_nodes_in_group("mek_scenes")
	
	structures.append_array(buildings)
	structures.append_array(towers)
	structures.append_array(stadiums)
	structures.append_array(districts)	

	old_pos = global_position;
	pos = global_position;
	
	
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):		
	#set pos to current position
	pos = global_position;
	if pos - old_pos:
		moving = true;
	else:
		moving = false;
	#create old pos from pos
	old_pos = pos;
		
	# Face towards moving direction
	last_position = this_position
	this_position = self.position

	if get_node("../BattleManager").spawning == false:
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

	#A star
	get_node("../TileMap").astar_grid.set_point_solid(tile_pos, true)

	if self.unit_level <= 0:
		self.get_child(10).text = " "	
	if self.unit_level == 1:
		self.get_child(10).text = "."					
	if self.unit_level == 2:
		self.get_child(10).text = ".."
	if self.unit_level == 3:
		self.get_child(10).text = "..."
	if self.unit_level == 4:
		self.get_child(10).text = "...."
	if self.unit_level == 5:
		self.get_child(10).text = "....."	
	if self.unit_level == 6:
		self.get_child(10).text = "......"
	if self.unit_level == 7:
		self.get_child(10).text = "......."
	if self.unit_level == 8:
		self.get_child(10).text = "........"
	if self.unit_level == 9:
		self.get_child(10).text = "........."
	if self.unit_level == 10:
		self.get_child(10).text = ".........."
	if self.unit_level == 11:
		self.get_child(10).text = "..........."				
	
	#Get cell id skew
	self.tile_id = get_node("../TileMap").get_cell_source_id(0, tile_pos) 
	if self.tile_id != 0:
		self.can_attack = true
		tween_loop()		
	elif self.tile_id == 0:
		self.can_attack = false	
		self.skew = 0	

	self.Levelprogressbar.max_value = self.xp_requirements	
	self.Levelprogressbar.set_value(self.xp)

	if moved == true:
		get_child(7).show()
		pass
	else:
		get_child(7).hide()
		modulate = Color8(255, 255, 255)
		
	if attacked == true:
		get_child(8).show()
		modulate = Color8(110, 110, 110)
		pass	
	else:
		get_child(8).hide()	
		modulate = Color8(255, 255, 255)		
		
	#Mouse hover
	if flag_coroutine == false:
		await get_tree().create_timer(0).timeout
		flag_coroutine = true

	#Thumbs while moving
	if moving == true:
		get_node("../Profile").get_child(1).texture = self.unit_portrait
		get_node("../Profile").get_child(2).text = unit_name
		if self.unit_team == 2:
			get_node("../Profile").get_child(3).texture = self.mek_portrait		
			get_node("../Profile").get_child(3).modulate = Color8(255, 110, 255) #mek portrait
			get_node("../Profile").get_child(4).text = str(self.unit_movement)
			get_node("../Profile").get_child(5).text = str(self.unit_defence)
			get_node("../Profile").get_child(6).text = str(self.unit_level)
			get_node("../Profile").get_child(13).text = str(self.unit_min) + "/" + str(self.progressbar.max_value)
			get_node("../Profile").get_child(14).text = "Level " + str(self.unit_level)
		else:
			get_node("../Profile").get_child(3).texture = self.mek_portrait		
			get_node("../Profile").get_child(3).modulate = Color8(255, 255, 255) #mek portrait			 
			get_node("../Profile").get_child(4).text = str(self.unit_movement)
			get_node("../Profile").get_child(5).text = str(self.unit_defence)
			get_node("../Profile").get_child(6).text = str(self.unit_level)	
			get_node("../Profile").get_child(13).text = str(self.unit_min) + "/" + str(self.progressbar.max_value)
			get_node("../Profile").get_child(14).text = "Level " + str(self.unit_level)		
			
	if tile_pos == mouse_local_pos and self.unit_team == 1:
		self.get_child(0).set_use_parent_material(false)
		if !get_node("../TileMap").get_child(1).is_playing() and audio_flag:
			audio_flag = false
			get_node("../Profile").show()
			get_node("../Profile").get_child(4).show()
			get_node("../Profile").get_child(5).show()
			get_node("../TileMap").get_child(1).stream = get_node("../TileMap").map_sfx[6]
			get_node("../TileMap").get_child(1).play()	
			get_node("../Profile").get_child(1).texture = self.unit_portrait
			get_node("../Profile").get_child(2).text = unit_name
			get_node("../Profile").get_child(3).texture = self.mek_portrait		
			get_node("../Profile").get_child(3).modulate = Color8(255, 255, 255) #mek portrait		
			get_node("../Profile").get_child(4).text = str(self.unit_movement)
			get_node("../Profile").get_child(5).text = str(self.unit_defence)
			get_node("../Profile").get_child(6).text = str(self.unit_level)	
			get_node("../Profile").get_child(13).text = str(self.unit_min) + "/" + str(self.progressbar.max_value)			
			get_node("../Profile").get_child(14).text = "Level " + str(self.unit_level)
			
			get_node("../Control").get_child(5).text = "LV. " + str(unit_level)
			get_node("../Control").get_child(6).text = "HP. " + str(unit_min)
			get_node("../Control").get_child(7).text = "ATK " + str(unit_attack)
			get_node("../Control").get_child(8).text = "DEF " + str(unit_defence)
			get_node("../Control").get_child(9).value = self.unit_min
			get_node("../Control").get_child(9).max_value = self.unit_max
			get_node("../Control").get_child(10).set_value(xp)
			get_node("../Control").get_child(10).max_value = self.xp_requirements			
			get_node("../Control").get_child(13).texture = self.mek_portrait
			get_node("../Control").get_child(13).modulate = Color8(255, 255, 255) #mek portrait
			hovered_unit = self.unit_num			
	else:
		audio_flag = true
		self.get_child(0).set_use_parent_material(true)

	if tile_pos == mouse_local_pos and self.unit_team == 2:
		if !get_node("../TileMap").get_child(1).is_playing() and audio_flag_2:
			audio_flag_2 = false	
			get_node("../Profile").show()
			get_node("../Profile").get_child(4).show()
			get_node("../Profile").get_child(5).show()
			get_node("../Profile").get_child(3).texture = self.mek_portrait		
			get_node("../Profile").get_child(3).modulate = Color8(255, 110, 255) #mek portrait		
			get_node("../TileMap").get_child(1).stream = get_node("../TileMap").map_sfx[6]
			get_node("../TileMap").get_child(1).play()	
			get_node("../Profile").get_child(1).texture = self.unit_portrait
			get_node("../Profile").get_child(2).text = unit_name
			get_node("../Profile").get_child(4).text = str(self.unit_movement)
			get_node("../Profile").get_child(5).text = str(self.unit_defence)
			get_node("../Profile").get_child(6).text = str(self.unit_level)		
			get_node("../Profile").get_child(13).text = str(self.unit_min) + "/" + str(self.progressbar.max_value)	
			get_node("../Profile").get_child(14).text = "Level " + str(self.unit_level)
			
			get_node("../Control").get_child(5).text = "LV. " + str(unit_level)
			get_node("../Control").get_child(6).text = "HP. " + str(unit_min)
			get_node("../Control").get_child(7).text = "ATK " + str(unit_attack)
			get_node("../Control").get_child(8).text = "DEF " + str(unit_defence)
			get_node("../Control").get_child(9).value = self.unit_min
			get_node("../Control").get_child(9).max_value = self.unit_max
			get_node("../Control").get_child(10).set_value(xp)			
			get_node("../Control").get_child(10).max_value = self.xp_requirements		
			get_node("../Control").get_child(13).texture = self.mek_portrait
			get_node("../Control").get_child(13).modulate = Color8(255, 110, 255) #mek portrait
			#hovered_unit = unit_num
	else:
		audio_flag_2 = true
		
	#Mek Coordinates
	mek_coord = get_node("../TileMap").local_to_map(self.position)
		
	# Z index layering
	self.z_index = tile_pos.x + tile_pos.y
		
	if self.xp >= self.xp_requirements:
		self.xp_requirements += 1
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
		self.Levelprogressbar.max_value += 1

		if self.unit_movement >= 5:				
			return
		else:
			self.unit_movement += 1
			
												
	if self.unit_min >= self.unit_max:
		self.unit_min = self.unit_max
	
	self.progressbar.set_value(self.unit_min)	
	
	
func check_health():
	var unit_global_position = self.position
	var unit_pos = get_node("../TileMap").local_to_map(unit_global_position)
	get_node("../TileMap").astar_grid.set_point_solid(unit_pos, true)
						
	#Structure collisions			
	for i in structures.size():
		var unit_center_pos = get_node("../TileMap").local_to_map(self.position)
		var structure_pos = get_node("../TileMap").local_to_map(structures[i].position)
		if unit_center_pos == structure_pos:
			self.unit_min = 0		
			get_node("../TileMap").structures[i].get_child(0).play("demolished")
			get_node("../TileMap").structures[i].get_child(0).modulate = Color8(255, 255, 255) 	
			#check_health()
			break
			
	# Check for Mek collisions	
	for i in meks.size():
		if meks[i] != self and self.position == meks[i].position:
			self.unit_min = 0
			meks[i].unit_min = 0	
			break
				
	# Check is off map
	for i in get_node("../BattleManager").available_units.size():
		var unit_center_position = get_node("../BattleManager").available_units[i].position
		var unit_position = get_node("../TileMap").local_to_map(unit_center_position)		
		if unit_pos.x < 0 or unit_pos.x > 15 or unit_pos.y < 0 or unit_pos.y > 15:
			self.unit_min = 0											
			break
				
	#Check health
	if self.unit_min <= 0 and only_once:
		only_once = false
		var unit_center_pos = self.position		
		var unit_cell_center_pos = get_node("../TileMap").map_to_local(unit_center_pos) + Vector2(0,0) / 2
		var explosion = preload("res://prefab/vfx/explosion_area_2d.tscn")
		var explosion_instance = explosion.instantiate()
		var explosion_pos = get_node("../TileMap").map_to_local(unit_cell_center_pos) + Vector2(0,0) / 2
		explosion_instance.set_name("explosion")
		get_parent().add_child(explosion_instance)
		explosion_instance.position = self.position	
		explosion_instance.z_index = (unit_center_pos.x + unit_center_pos.y) + 100
		self.unit_status = "Inactive"
		self.add_to_group("Inactive")
		if self.unit_team == 1:
			self.add_to_group("USER Inactive")
		elif self.unit_team == 2:
			self.add_to_group("CPU Inactive")
		get_node("../Camera2D").shake(0.5, 50, 8)
		self.hide()
		self.position = Vector2(1000,1000)	
		print(self.unit_name, " DESTROYED: Team ",  get_node("../BattleManager").available_units[unit_num].unit_team, " NO. " , get_node("../BattleManager").available_units[unit_num].unit_num)

		#Remove hover tiles										
		for l in 16:
			for k in 16:
				get_node("../TileMap").set_cell(1, Vector2i(l,k), -1, Vector2i(0, 0), 0)			
		
		await get_tree().create_timer(1).timeout


func get_closest_player_or_null_CPU():
	var all_players = get_tree().get_nodes_in_group("USER_Team")
	var closest_player = null
 
	if (all_players.size() > 0):
		closest_player = all_players[0]
		for player in all_players:
			var distance_to_this_player = global_position.distance_squared_to(player.global_position)	
			var distance_to_closest_player = global_position.distance_squared_to(closest_player.global_position)
			if (distance_to_this_player < distance_to_closest_player):
				closest_player = player
				
	return closest_player


func get_closest_player_or_null_USER():
	var all_players = get_tree().get_nodes_in_group("CPU_Team")
	var closest_player = null
 
	if (all_players.size() > 0):
		closest_player = all_players[0]
		for player in all_players:
			var distance_to_this_player = global_position.distance_squared_to(player.global_position)	
			var distance_to_closest_player = global_position.distance_squared_to(closest_player.global_position)
			if (distance_to_this_player < distance_to_closest_player):
				closest_player = player				
	return closest_player

func tween_loop():
	tween = create_tween().set_loops(10)
	tween.tween_property(self, "skew", -0.1, 1).from(0.1)
	tween.tween_property(self, "skew", 0.1, 1).from(-0.1)		
