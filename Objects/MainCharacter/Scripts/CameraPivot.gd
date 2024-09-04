extends Marker2D

@onready var player = owner as Player
#
#func _ready():
	#player.u_turn.connect(_on_player_u_turn)
	
	
func _on_player_u_turn():
	print("Player u_turn")
