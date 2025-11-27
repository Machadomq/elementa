extends Area2D

@onready var label_interacao = $Sprite2D        # seu sprite original
@onready var tween := create_tween()

var player_in_area = false
var dialog_active = false


func _ready() -> void:
	label_interacao.visible = false
	label_interacao.modulate.a = 0.0  # começa invisível


# Quando o jogador entra na área
func _on_body_entered(body) -> void:
	if body.name == "player":
		player_in_area = true
		_show_interaction_label()


# Quando o jogador sai da área
func _on_body_exited(body) -> void:
	if body.name == "player":
		player_in_area = false
		_hide_interaction_label()

		if dialog_active:
			Dialogic.end_timeline()   # fecha diálogo automaticamente
			dialog_active = false


# --- FUNÇÕES DE ANIMAÇÃO DO LABEL ---

# Fade in
func _show_interaction_label() -> void:
	label_interacao.visible = true
	tween.kill()
	tween = create_tween()
	tween.tween_property(label_interacao, "modulate:a", 1.0, 0.1)


# Fade out
func _hide_interaction_label() -> void:
	tween.kill()
	tween = create_tween()
	tween.tween_property(label_interacao, "modulate:a", 0.0, 0.3)
	await tween.finished
	label_interacao.visible = false


# --- PROCESSO DE INTERAÇÃO ---
func _process(delta) -> void:
	if player_in_area \
	and not dialog_active \
	and Input.is_action_just_pressed("INTERACT"):

		dialog_active = true
		Dialogic.start("npc3")  # sua timeline original
