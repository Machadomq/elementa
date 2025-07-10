extends Area2D

@export var dialogue_path = "res://data/dialogues/introducao.dtl"
var player_near = false

func _process(_delta):
	if player_near and Input.is_action_just_pressed("ui_accept"):
		Dialogic.start(dialogue_path)

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_near = true

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_near = false
