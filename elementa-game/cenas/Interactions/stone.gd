extends Area2D

@onready var label_interacao = $Sprite2D
@onready var eletric1 = $eletri1
@onready var eletric2 = $eletri2
@onready var luz = $luz

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
		Dialogic.start("stone1")
		desaparecer_elementos()

func desaparecer_elementos() -> void:
	await get_tree().create_timer(0.0).timeout
	eletric1.visible = false
	eletric2.visible = false
	luz.visible = false

func _ready() -> void: 
	label_interacao.visible = false
	eletric1.visible = true
	eletric2.visible = true
	luz.visible = true	
