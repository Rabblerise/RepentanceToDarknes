class_name Player
extends CharacterBody2D

var input_actions := ["Jump", "goRight", "goLeft"]
var state: FSM_State = FSM_State_Idle.new(self)

const SPEED : float = 300.0
const MAX_JUMP_TIME : float = 0.3
const MAX_JUMP_HEIGHT  : float = -300.0
const JUMP_ACCELERATION : float = -1500.0
const DASH_SPEED : float = 1500.0
const DASH_DURATION : float = 0.2
const DASH_COOLDOWN : float = 1.0
const RESPAWN_HEIGHT : float = 1000.0

signal u_turn
signal animation_finished

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var jump_timer = 0
var dash_timer = 0
var is_jumping = false
var can_dash = true
var respawn_position = Vector2.ZERO
var last_direction = Vector2.RIGHT

var animated_sprite: AnimationPlayer
var skeleton : Skeleton2D

@onready var AudioMovePlayer = $Move
@onready var AudioJumpPlayer = $Jump	

func _ready():
	respawn_position = position
	animated_sprite = $PlayerSprites/AnimationPlayer
	skeleton = $PlayerSprites/RightPose
	animated_sprite.connect("animation_finished", on_animation_finished)

func _process(delta):
	var actions := []
	for action in input_actions:
		if Input.is_action_pressed(action):
			actions.append(action)
	var fsm_input = FSM_Meta.FSM_Input.new(actions, is_on_floor())
	var new_state_id = state.input(fsm_input)
	if new_state_id != FSM_Meta.FSM_States.None:
		var _new_state = get_new_state(new_state_id)
		state.exit()
		state = _new_state
		state.enter()
	state.update(fsm_input, delta)
			
	if is_on_floor() and Input.is_action_just_pressed("Jump"):
		is_jumping = true
		jump_timer = 0
		velocity.y = MAX_JUMP_HEIGHT
	elif Input.is_action_pressed("Jump") and is_jumping:
		jump_timer += delta
		velocity.y += JUMP_ACCELERATION * delta
		if jump_timer > MAX_JUMP_TIME:
			is_jumping = false

	if Input.is_action_just_pressed("Dash") and can_dash:
		dash_timer = DASH_DURATION
		can_dash = false

func _physics_process(delta):
	if !is_on_floor():
		velocity.y += gravity * delta

	var direction = Input.get_action_strength("goRight") - Input.get_action_strength("goLeft")
	if direction != 0:
		update_direction(direction)
		velocity.x = direction * SPEED
	else:
		velocity.x = 0

	if dash_timer > 0:
		if direction == 0:
			direction = last_direction.x
		velocity.x = DASH_SPEED * direction
		dash_timer -= delta
		
		if dash_timer <= 0:
			velocity.x = 0
			
	if position.y > RESPAWN_HEIGHT:
			position = respawn_position

	move_and_slide()

	if is_on_floor():
		respawn_position = position
		is_jumping = false
		can_dash = true
	
func get_new_state(state_id: int):
	match state_id:
		FSM_Meta.FSM_States.Idle:
			if AudioJumpPlayer.playing or AudioMovePlayer.playing:
				AudioJumpPlayer.stop()
				AudioMovePlayer.stop()
			return FSM_State_Idle.new(self)
		FSM_Meta.FSM_States.Move:
			if !AudioMovePlayer.playing and is_on_floor():
				AudioMovePlayer.play()
			return FSM_State_Move.new(self)
		FSM_Meta.FSM_States.Jump:
			if !AudioJumpPlayer.playing:
				AudioMovePlayer.stop()
				AudioJumpPlayer.play()
			return FSM_State_Jump.new(self)
	push_error("Invalid state ID: %d" % state_id)
	
func play_animation(animation: String):
	animated_sprite.play(animation)

func flip_h(condition: bool):
	if condition:
		skeleton.set_bone_local_pose_override(0, Transform2D(Vector2(-1, 0), Vector2(0, 1), Vector2.ZERO), 1.0, true)
	else:
		skeleton.set_bone_local_pose_override(0, Transform2D(Vector2(1, 0), Vector2(0, 1), Vector2.ZERO), 1.0, true)
	
func on_animation_finished():
	emit_signal("animation_finished")

func update_direction(direction: float):
	if direction > 0 and last_direction == Vector2.LEFT:
		last_direction = Vector2.RIGHT
		u_turn.emit("left")
		play_animation("walk")

	elif direction < 0 and last_direction == Vector2.RIGHT:
		last_direction = Vector2.LEFT
		u_turn.emit("right")
		play_animation("walk")
	elif direction == 0:
		play_animation("idle")
		flip_h(false)
