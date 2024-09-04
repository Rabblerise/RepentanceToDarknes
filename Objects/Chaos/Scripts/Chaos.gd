extends CharacterBody2D

@onready var player = owner as Player

var movement_area = Rect2(0, -50, 150, 150)
var target_position = Vector2.ZERO

var move_speed : int = 200 # Скорость перемещения объекта


# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(true)
	set_target_position()
	player.u_turn.connect(test_emit)
	
func test_emit(side):
	if side == "left":
		movement_area.position.x = 0
	else:
		movement_area.position.x = -300
	set_target_position()
	
func set_target_position():
	target_position.x  = randi_range(movement_area.position.x, movement_area.position.x + movement_area.size.x)
	target_position.y = randi_range(movement_area.position.y, movement_area.position.y + movement_area.size.y)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):	
	var directionTarget = (target_position + player.position - global_position).normalized()
	if (player.position + global_position * delta).normalized().distance_to(directionTarget) < 1.45:
		set_target_position()
		
	velocity = directionTarget * move_speed
	move_and_slide()



