extends Area2D

@onready var label_interacao = $Sprite2D2
@onready var tween := create_tween()

var player_in_area = false
var dialog_active = false

func _ready() -> void:
	label_interacao.visible = false
	label_interacao.modulate.a = 0.0  # deixa invisível (transparente)

# Quando o jogador entra na área
func _on_body_entered(body: Node) -> void:
	if body.name == "player":
		player_in_area = true
		_show_interaction_label()

# Quando o jogador sai da área
func _on_body_exited(body: Node) -> void:
	if body.name == "player":
		player_in_area = false
		_hide_interaction_label()
		if dialog_active:
			Dialogic.end_timeline()  # Fecha o diálogo automaticamente
			dialog_active = false

# Mostra o ícone/label com efeito de fade in
func _show_interaction_label():
	label_interacao.visible = true
	tween.kill()  # garante que não há tweens antigos
	tween = create_tween()
	tween.tween_property(label_interacao, "modulate:a", 1.0, 0.1)  # fade in suave

# Esconde o ícone/label com efeito de fade out
func _hide_interaction_label():
	tween.kill()
	tween = create_tween()
	tween.tween_property(label_interacao, "modulate:a", 0.0, 0.3)  # fade out suave
	await tween.finished
	label_interacao.visible = false

# Detecta interação do jogador
func _process(delta: float) -> void:
	if player_in_area and not dialog_active and Input.is_action_just_pressed("INTERACT"):
		dialog_active = true
		Dialogic.start("npc-inicial")  # nome da timeline do Dialogic

		
