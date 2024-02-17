extends ProgressBar

@export var node2D: Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.value = node2D.progresscount
		
	if self.value >= 1025:
		self.hide()
