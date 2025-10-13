extends Area2D

@onready var label = $CanvasLayer/MarginContainer/Label

var has_played = false

func _ready() -> void:
	label.visible = false

func _on_body_entered(body: Node2D) -> void:
	if body.name == "player" and not has_played:
		has_played = true
		label.visible = true
		label.play_sequence()
		
