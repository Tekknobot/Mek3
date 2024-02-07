extends Control

var dirt = preload("res://assets/iso_tiles/dirt.png")
var snow = preload("res://assets/iso_tiles/grass_snow.png")
var ice = preload("res://assets/iso_tiles/ice_single.png")
var grass = preload("res://assets/iso_tiles/grass_default.png")
var sandstone = preload("res://assets/iso_tiles/sandstone.png")
var water = preload("res://assets/iso_tiles/water_single.png")

var road = preload("res://assets/iso_tiles/roads/17.png")
var road2 = preload("res://assets/iso_tiles/roads/18.png")
var intersection = preload("res://assets/iso_tiles/roads/16.png")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var mouse_pos = get_global_mouse_position()
	var mouse_local_pos = get_node("../TileMap").local_to_map(mouse_pos)	
	
	var tile_id = get_node("../TileMap").get_cell_source_id(0, mouse_local_pos) 
	
	if tile_id == 0:
		get_child(2).texture = water
		get_child(3).text = "water"
		get_child(4).text = "-1 ATK"
	if tile_id == 1:
		get_child(2).texture = sandstone
		get_child(3).text = "sandstone"
		get_child(4).text = "+1 ATK"
	if tile_id == 2:
		get_child(2).texture = dirt
		get_child(3).text = "dirt"
		get_child(4).text = "No effect"
	if tile_id == 3:
		get_child(2).texture = grass
		get_child(3).text = "grass"
		get_child(4).text = "No effect"		
	if tile_id == 4:
		get_child(2).texture = snow
		get_child(3).text = "snow"
		get_child(4).text = "-1 DEF"
	if tile_id == 5:
		get_child(2).texture = ice	
		get_child(3).text = "ice"
		get_child(4).text = "-1 DEF"						
	if tile_id == 41:
		get_child(2).texture = road	
		get_child(3).text = "road"	
		get_child(4).text = "No Effect"		
	if tile_id == 42:
		get_child(2).texture = road2
		get_child(3).text = "road"	
		get_child(4).text = "No Effect"
	if tile_id == 43:
		get_child(2).texture = intersection	
		get_child(3).text = "intersection"		
		get_child(4).text = "No Effect"	