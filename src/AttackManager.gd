extends Node2D

@export var node2D: Node2D
var projectile = preload("res://scenes/projectile.scn")

@onready var line_2d = $"../Line2D"
@onready var post_a = $"../postA"
@onready var pre_b = $"../preB"
@onready var sprite_2d = $"../Sprite2D"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_Q:
			get_node("../AttackManager").death_from_above()

func death_from_above():
	for i in get_node("../BattleManager").available_units.size():
		if get_node("../BattleManager").available_units[i].unit_team == 2:
			var mek_position = get_node("../TileMap").map_to_local(get_node("../BattleManager").available_units[i].mek_coord) + Vector2(0,0) / 2
			await setLinePointsToBezierCurve(line_2d, Vector2(mek_position.x, mek_position.y-250), Vector2(0,0), Vector2(0,0), get_node("../BattleManager").available_units[i].global_position)										
			var tween: Tween = create_tween()
			tween.tween_property(get_node("../BattleManager").available_units[i], "modulate:v", 1, 0.50).from(5)														
			get_node("../BattleManager").available_units[i].unit_min -= 1
			get_node("../BattleManager").available_units[i].progressbar.set_value(get_node("../BattleManager").available_units[i].unit_min)
			get_node("../BattleManager").available_units[i].check_health()
			
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
