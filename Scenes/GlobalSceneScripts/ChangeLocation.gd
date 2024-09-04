extends Node2D
class_name ChangeLocation

@export var next_scene : String
@export var next_scene_index : int
@onready var scene : Node2D

const MAX_BLIND_TIME = 1
var onPosition : bool = false
var isAction : bool = false
var blindTimer : float = 0

signal nextEnrty 

func _ready():
	scene = get_tree().root.get_child(0)

func _process(delta):
	if isAction:
		blindTimer += delta / 2
		scene.modulate.a -= delta
		
	if Input.is_action_just_pressed("Action") and onPosition:
		isAction = true
	
	if blindTimer > MAX_BLIND_TIME:	
		blindTimer = 0
		isAction = false
		get_tree().change_scene_to_file(next_scene)

func _on_to_next_scene_body_entered(body):
	if body.name != "Player":
		return
	onPosition = true

func _on_to_next_scene_body_exited(body):
	if body.name != "Player":
		return
	onPosition = false
