extends Area2D

@onready var textura_fechada = $fechada
@onready var textura_aberta = $aberta


var player_in_area = false
var errou : bool = false 

func _on_body_entered(body) -> void:
	if body.name == "player": 
		player_in_area = true


func _on_body_exited(body) -> void:
	if body.name == "player": 
		player_in_area = false


func _on_dialogic_signal(arg : String):
	if arg == "acertou":
		errou = true
		textura_fechada.visible = false
		textura_aberta.visible = true
	else:
		pass
	
func _process(delta) -> void:
	if player_in_area and Input.is_action_just_pressed("INTERACT"):
		Dialogic.signal_event.connect(_on_dialogic_signal)
		Dialogic.start("puzzle1")

func _ready() -> void: 
	textura_fechada.visible = true
	textura_aberta.visible = false
