extends Area2D

@onready var label_interacao = $Sprite2D

var player_in_area = false

func _on_body_entered(body) -> void:
	if body.name == "player": 
		player_in_area = true
		label_interacao.visible = true


func _on_body_exited(body) -> void:
	if body.name == "player": 
		player_in_area = false
		label_interacao.visible = false

func _process(_delta) -> void:
	if player_in_area and Input.is_action_just_pressed("INTERACT"):
		Dialogic.start("placadupla")
		


func _ready() -> void: 
	label_interacao.visible = false
	
