extends FSM_State
class_name FSM_State_Idle

const DEFAULT_ANIMATION := "idle1"
const ALTERNATIVE_ANIMATIONS := ["idle2", "idle3"]
const ANIMATION_INTERVAL := 5.0

var rng := RandomNumberGenerator.new()
var time_to_alternative_animation := ANIMATION_INTERVAL

func _init(_agent : CharacterBody2D):
	agent = _agent
	rng.randomize()
	
func input(fsm_input: FSM_Meta.FSM_Input) -> int:
	if "Jump" in fsm_input.actions:
		return FSM_Meta.FSM_States.Jump
	elif "goRight" in fsm_input.actions or "goLeft" in fsm_input.actions:
		return FSM_Meta.FSM_States.Move
	return FSM_Meta.FSM_States.None

func update(_fsm_input: FSM_Meta.FSM_Input, delta: float):
	time_to_alternative_animation -= delta
	if time_to_alternative_animation <= 0:
		var animation = ALTERNATIVE_ANIMATIONS[rng.randi_range(0, ALTERNATIVE_ANIMATIONS.size() - 1)]
		agent.play_animation(animation)
		time_to_alternative_animation = ANIMATION_INTERVAL

func enter():
	agent.play_animation(DEFAULT_ANIMATION)


