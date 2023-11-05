# this class is basically 'The Stack in MTG'. each turn contains all the actions
# and we process them however we need to, could be first in last out, etc
extends Node2D
class_name TurnStack

signal turn_over

func add_node(node: Area2D) -> void:
	get_node("../TileMap").unitsArray.append(node)

func remove_node(node: Area2D) -> void:
	if get_node("../TileMap").unitsArray.is_empty(): return

	get_node("../TileMap").unitsArray.erase(node)

	if get_node("../TileMap").unitsArray.is_empty():
		emit_signal('turn_over')
