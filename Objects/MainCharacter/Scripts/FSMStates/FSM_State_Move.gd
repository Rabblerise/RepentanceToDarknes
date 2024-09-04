extends FSM_State
class_name FSM_State_Move

func input(fsm_input: FSM_Meta.FSM_Input) -> int:
	if "Jump" in fsm_input.actions:
		return FSM_Meta.FSM_States.Jump
	elif not "goRight" in fsm_input.actions and not "goLeft" in fsm_input.actions:
		return FSM_Meta.FSM_States.Idle
	return FSM_Meta.FSM_States.None

func update(fsm_input: FSM_Meta.FSM_Input, _delta: float):
	agent.velocity.x = int(fsm_input.actions.has("goRight")) - int(fsm_input.actions.has("goLeft"))
	agent.velocity.x *= agent.SPEED
	agent.flip_h(agent.velocity.x < 0)
	
	
func enter():
	agent.play_animation("move")



