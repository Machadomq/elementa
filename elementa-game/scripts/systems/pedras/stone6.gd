extends Area2D

@onready var label_interacao = $Sprite2D
@onready var eletric1 = $eletri1
@onready var eletric2 = $eletri2
@onready var luz = $luz
@onready var tween := create_tween()

var player_in_area = false
var dialog_active = false


func _ready() -> void:
	label_interacao.visible = false
	label_interacao.modulate.a = 0.0  # deixa o label invisível

	eletric1.visible = true
	eletric2.visible = true
	luz.visible = true


# -----------------------------
# ENTRADA / SAÍDA DO PLAYER
# -----------------------------
func _on_body_entered(body) -> void:
	if body.name == "player":
		player_in_area = true
		_show_interaction_label()


func _on_body_exited(body) -> void:
	if body.name == "player":
		player_in_area = false
		_hide_interaction_label()

		if dialog_active:
			Dialogic.end_timeline()
			dialog_active = false


# -----------------------------
# INTERAÇÃO
# -----------------------------
func _process(_delta) -> void:
	if player_in_area \
	and not dialog_active \
	and Input.is_action_just_pressed("INTERACT"):

		dialog_active = true
		Dialogic.start("stone6")
		desaparecer_elementos()


# -----------------------------
# FADE IN / FADE OUT DO ÍCONE
# -----------------------------
func _show_interaction_label() -> void:
	label_interacao.visible = true
	tween.kill()
	tween = create_tween()
	tween.tween_property(label_interacao, "modulate:a", 1.0, 0.15)  # fade in


func _hide_interaction_label() -> void:
	tween.kill()
	tween = create_tween()
	tween.tween_property(label_interacao, "modulate:a", 0.0, 0.25)  # fade out
	await tween.finished
	label_interacao.visible = false


# -----------------------------
# DESAPARECER ELEMENTOS
# -----------------------------
func desaparecer_elementos() -> void:
	await get_tree().create_timer(0.0).timeout
	eletric1.visible = false
	eletric2.visible = false
	luz.visible = false
