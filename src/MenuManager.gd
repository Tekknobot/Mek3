extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func start_level():
	get_tree().change_scene_to_file("res://scenes/node_2d.tscn")

func quit_game():
	get_tree().quit()
