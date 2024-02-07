extends Control

@export var node2D: Node2D

var building = preload("res://assets/structures/pics/building_pic.png")
var tower = preload("res://assets/structures/pics/tower_pic.png")
var stadium = preload("res://assets/structures/pics/stadium_pic.png")
var district = preload("res://assets/structures/pics/district_pic.png")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var mouse_pos = get_global_mouse_position()
	var mouse_local_pos = get_node("../TileMap").local_to_map(mouse_pos)	
	
	var buildings = get_tree().get_nodes_in_group("buildings")
	var towers = get_tree().get_nodes_in_group("towers")
	var stadiums = get_tree().get_nodes_in_group("stadiums")
	var districts = get_tree().get_nodes_in_group("districts")
	
	for i in node2D.structures.size():
		var structure_pos = get_node("../TileMap").local_to_map(node2D.structures[i].position)
		if mouse_local_pos != structure_pos:
			get_child(2).texture = null
			get_child(3).text = " "	
			self.hide()			
	
	for i in buildings.size():
		var building_local_pos = get_node("../TileMap").local_to_map(buildings[i].position)
		if mouse_local_pos == building_local_pos:
			get_child(2).texture = building
			get_child(3).text = "building"	
			self.show()		

	for i in towers.size():
		var towers_local_pos = get_node("../TileMap").local_to_map(towers[i].position)
		if mouse_local_pos == towers_local_pos:
			get_child(2).texture = tower
			get_child(3).text = "tower"
			self.show()	
			
	for i in stadiums.size():
		var stadiums_local_pos = get_node("../TileMap").local_to_map(stadiums[i].position)
		if mouse_local_pos == stadiums_local_pos:
			get_child(2).texture = stadium
			get_child(3).text = "stadium"
			self.show()	
			
	for i in districts.size():
		var districts_local_pos = get_node("../TileMap").local_to_map(districts[i].position)
		if mouse_local_pos == districts_local_pos:
			get_child(2).texture = district		
			get_child(3).text = "district"			
			self.show()		
