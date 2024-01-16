extends Node2D
class_name TurnManager

enum { USER_TURN, CPU_TURN }

var turn: int = USER_TURN:
	get:
		return turn
	set(value):
		turn = value
		match turn:
			USER_TURN:
				user_turn_started.emit()
			CPU_TURN:
				cpu_turn_started.emit()


signal user_turn_started
signal user_turn_ended
signal cpu_turn_started

var available_units = []

func start() -> void:
	self.turn = USER_TURN

func advance_turn() -> void:	
	print('advancing turn')	
	
	# if value is 0, set to 1. if value is 1, set to 0 - binary operation
	self.turn = int(self.turn + 1) & 1
