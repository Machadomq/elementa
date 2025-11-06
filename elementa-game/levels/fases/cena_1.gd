extends Node2D
@onready var player = $player
@onready var sfx_door = $sfx_door as AudioStreamPlayer2D

func _ready() -> void:
	if Global.destination_level != "": 
		var point = get_node(Global.destination_level)
		if point:
			player.global_position = point.global_position
			
			
