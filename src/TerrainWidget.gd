extends Control

var dirt = preload("res://assets/iso_tiles/dirt.png")
var snow = preload("res://assets/iso_tiles/grass_snow.png")
var ice = preload("res://assets/iso_tiles/ice_single.png")
var grass = preload("res://assets/iso_tiles/grass_default.png")
var sandstone = preload("res://assets/iso_tiles/sandstone.png")
var water = preload("res://assets/iso_tiles/water_single.png")

var dirt_mars = preload("res://assets/iso_tiles/mars/dirt_mars.png")
var snow_mars = preload("res://assets/iso_tiles/mars/grass_snow_mars.png")
var ice_mars = preload("res://assets/iso_tiles/mars/ice_mars_single.png")
var grass_mars = preload("res://assets/iso_tiles/mars/grass_mars.png")
var sandstone_mars = preload("res://assets/iso_tiles/mars/sandstone_mars.png")
var water_mars = preload("res://assets/iso_tiles/mars/water_mars_single.png")

var dirt_moon = preload("res://assets/iso_tiles/moon/dirt_moon.png")
var snow_moon = preload("res://assets/iso_tiles/moon/grass_snow_moon.png")
var ice_moon = preload("res://assets/iso_tiles/moon/ice_moon_single.png")
var grass_moon = preload("res://assets/iso_tiles/moon/grass_moon.png")
var sandstone_moon = preload("res://assets/iso_tiles/moon/sandstone_moon.png")
var water_moon = preload("res://assets/iso_tiles/moon/water_moon_single.png")

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
		get_child(4).text = "Cannot attack from water."
	if tile_id == 1:
		get_child(2).texture = sandstone
		get_child(3).text = "sandstone"
		get_child(4).text = "No Effect"
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
		get_child(4).text = "No Effect"
	if tile_id == 5:
		get_child(2).texture = ice	
		get_child(3).text = "ice"
		get_child(4).text = "No Effect"						
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
		

		
	if tile_id == 49:
		get_child(2).texture = water_mars
		get_child(3).text = "water"
		get_child(4).text = "Cannot attack from water."
	if tile_id == 50:
		get_child(2).texture = sandstone_mars
		get_child(3).text = "sandstone"
		get_child(4).text = "No Effect"
	if tile_id == 51:
		get_child(2).texture = dirt_mars
		get_child(3).text = "dirt"
		get_child(4).text = "No effect"
	if tile_id == 52:
		get_child(2).texture = grass_mars
		get_child(3).text = "grass"
		get_child(4).text = "No effect"		
	if tile_id == 53:
		get_child(2).texture = snow_mars
		get_child(3).text = "snow"
		get_child(4).text = "No Effect"
	if tile_id == 54:
		get_child(2).texture = ice_mars
		get_child(3).text = "ice"
		get_child(4).text = "No Effect"						



	if tile_id == 55:
		get_child(2).texture = water_moon
		get_child(3).text = "water"
		get_child(4).text = "Cannot attack from water."
	if tile_id == 56:
		get_child(2).texture = sandstone_moon
		get_child(3).text = "sandstone"
		get_child(4).text = "No Effect"
	if tile_id == 57:
		get_child(2).texture = dirt_moon
		get_child(3).text = "dirt"
		get_child(4).text = "No effect"
	if tile_id == 58:
		get_child(2).texture = grass_moon
		get_child(3).text = "grass"
		get_child(4).text = "No effect"		
	if tile_id == 59:
		get_child(2).texture = snow_moon
		get_child(3).text = "snow"
		get_child(4).text = "No Effect"
	if tile_id == 60:
		get_child(2).texture = ice_moon
		get_child(3).text = "ice"
		get_child(4).text = "No Effect"				
