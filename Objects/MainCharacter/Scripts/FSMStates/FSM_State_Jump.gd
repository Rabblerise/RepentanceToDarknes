extends FSM_State
class_name FSM_State_Jump

func input(fsm_input: FSM_Meta.FSM_Input) -> int:
	if fsm_input.is_on_floor:
		if fsm_input.actions.has("goRight") or fsm_input.actions.has("goLeft"):
			return FSM_Meta.FSM_States.Move
		else:
			return FSM_Meta.FSM_States.Idle
	return FSM_Meta.FSM_States.None

func update(fsm_input: FSM_Meta.FSM_Input, _delta: float):
	agent.velocity.x = int(fsm_input.actions.has("goRight")) - int(fsm_input.actions.has("goLeft"))
	agent.velocity.x *= agent.SPEED
	agent.flip_h(agent.velocity.x < 0)

func enter():
	agent.velocity.y = agent.MAX_JUMP_HEIGHT
	agent.play_animation("jump")
