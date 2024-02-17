extends Node

var tile_pos

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.tile_pos = get_node("../TileMap").local_to_map(self.position)
	# Z index layering
	self.z_index = tile_pos.x + tile_pos.y
