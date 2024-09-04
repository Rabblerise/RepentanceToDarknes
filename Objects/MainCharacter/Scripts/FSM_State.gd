extends Node
class_name FSM_State

var agent : CharacterBody2D

func _init(_agent: CharacterBody2D):
	agent = _agent
	
func input(_fsm_input: FSM_Meta.FSM_Input) -> int:
	return FSM_Meta.FSM_States.None
	
func update(_fsm_input: FSM_Meta.FSM_Input, _delta: float) -> void:
	pass

func enter() -> void:
	pass
	
func exit() -> void:
	pass



