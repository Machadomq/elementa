extends Area2D

@onready var label_interacao = $Sprite2D
@onready var tween = create_tween()

var player_in_area = false

func _ready() -> void:
	label_interacao.visible = true
	label_interacao.modulate.a = 0.0  # Começa invisível


func _on_body_entered(body) -> void:
	if body.name == "player":
		player_in_area = true
		tween.kill()
		tween = create_tween()
		tween.tween_property(label_interacao, "modulate:a", 1.0, 0.1)  # Fade in rápido


func _on_body_exited(body) -> void:
	if body.name == "player":
		player_in_area = false
		# Fecha o diálogo ativo, se houver
		if Dialogic.current_timeline != null:
			Dialogic.end_timeline()
		# Fade out suave
		tween.kill()
		tween = create_tween()
		tween.tween_property(label_interacao, "modulate:a", 0.0, 0.3)


func _process(_delta) -> void:
	if player_in_area and Input.is_action_just_pressed("INTERACT"):
		Dialogic.start("placasimples")
