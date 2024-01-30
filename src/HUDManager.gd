extends Control

@export var node2D: Node2D
@export var seeker: Area2D

var projectile = preload("res://scenes/projectile.scn")
var explosion = preload("res://prefab/vfx/explosion_area_2d.tscn")

@onready var line_2d = $"../Line2D"
@onready var post_a = $"../postA"
@onready var pre_b = $"../preB"
@onready var sprite_2d = $"../Sprite2D"

var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_5:
			seek_and_destroy()

func death_from_above():
	get_node("../Control").get_child(14).hide()
	for i in get_node("../BattleManager").available_units.size():
		if get_node("../BattleManager").available_units[i].unit_team == 2 and get_node("../BattleManager").available_units[i].unit_status == "Active":
			var mek_position = get_node("../TileMap").map_to_local(get_node("../BattleManager").available_units[i].mek_coord) + Vector2(0,0) / 2
			get_node("../TileMap").set_cell(1, get_node("../BattleManager").available_units[i].mek_coord, 48, Vector2i(0, 0), 0)
			get_node("../TileMap").get_child(1).stream = get_node("../TileMap").map_sfx[1]
			get_node("../TileMap").get_child(1).play()					
			await SetLinePoints(line_2d, Vector2(mek_position.x, mek_position.y-250), Vector2(0,0), Vector2(0,0), get_node("../BattleManager").available_units[i].global_position)										
			var tween: Tween = create_tween()
			tween.tween_property(get_node("../BattleManager").available_units[i], "modulate:v", 1, 0.50).from(5)														
			get_node("../BattleManager").available_units[i].unit_min -= 1
			get_node("../BattleManager").available_units[i].progressbar.set_value(get_node("../BattleManager").available_units[i].unit_min)
			get_node("../BattleManager").available_units[i].check_health()

func group_health():
	get_node("../Control").get_child(15).hide()
	for i in get_node("../BattleManager").available_units.size():
		if get_node("../BattleManager").available_units[i].unit_team == 1:
			get_node("../TileMap").set_cell(1, get_node("../BattleManager").available_units[i].mek_coord, 18, Vector2i(0, 0), 0)
			get_node("../TileMap").get_child(1).stream = get_node("../TileMap").map_sfx[7]
			get_node("../TileMap").get_child(1).play()	
			await get_tree().create_timer(0.5).timeout
			var tween: Tween = create_tween()
			tween.tween_property(get_node("../BattleManager").available_units[i], "modulate:v", 1, 0.50).from(5)														
			get_node("../BattleManager").available_units[i].unit_min += 1
			get_node("../BattleManager").available_units[i].progressbar.set_value(get_node("../BattleManager").available_units[i].unit_min)
			get_node("../BattleManager").available_units[i].check_health()						
			

func seek_and_destroy():
		seeker.show()
		var patharray = get_node("../TileMap").astar_grid.get_point_path(Vector2i(0, 0), Vector2i(15, 15))				
		#Erase hover tiles
		for j in 16:
			for k in 16:
				get_node("../TileMap").set_cell(1, Vector2i(j,k), -1, Vector2i(0, 0), 0)
		
		# Set hover cells
		for h in patharray.size():
			print(patharray[h])
			await get_tree().create_timer(0.2).timeout
			get_node("../TileMap").set_cell(1, patharray[h], 48, Vector2i(0, 0), 0)	
			var tile_center_position = get_node("../TileMap").map_to_local(patharray[h]) + Vector2(0,0) / 2
			seeker.position = tile_center_position
			seeker.z_index = seeker.position.x + seeker.position.y
			var tween: Tween = create_tween()
			tween.tween_property(seeker, "position", tile_center_position, 1).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)	
		
		seeker.hide()
								
func SetLinePoints(line: Line2D, a: Vector2, postA: Vector2, preB: Vector2, b: Vector2):
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
