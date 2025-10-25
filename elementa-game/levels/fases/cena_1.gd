extends Node2D
@onready var player = $player

func _ready() -> void:
	pass
	if Global.destination_level != " ": 
		var point = get_node(Global.destination_level)
		if point:
			player.global_position = point.global_position
			
