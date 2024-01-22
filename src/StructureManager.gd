extends Area2D

@export var structure_type: String
@export var demolished_texture: Texture2D
@onready var Map = $TileMap

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):	
	#var tile_pos = get_node("../TileMap").local_to_map(self.position)	
	#self.z_index = tile_pos.x + tile_pos.y
	pass
