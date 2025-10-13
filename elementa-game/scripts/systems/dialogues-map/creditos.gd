extends Label

var typing_speed := 0.05
var display_time := 0.9  # quanto tempo cada texto fica na tela

# Sequência de textos
var messages: Array[String] = [
	"Jogo desenvolvido por",
	"Calian Dalari",
	"Erik Locatelli",
	"Gabriel Machado",
	"Guilherme Ehlert",
	"Ricardo Carodozo"
]

# Controla se está rodando a sequência
var running_sequence := false

# ---- EFEITO PRINCIPAL ----
func _type_text(full_text: String) -> void:
	text = ""
	for i in full_text.length():
		text += full_text[i]
		await get_tree().create_timer(typing_speed).timeout

# ---- FADE IN / OUT ----
func _fade_in():
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.5)

func _fade_out():
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)

# ---- MOSTRAR UMA FRASE ----
func show_message(msg: String) -> void:
	modulate.a = 0.0
	await _fade_in()
	await _type_text(msg)
	await get_tree().create_timer(display_time).timeout
	await _fade_out()

# ---- RODAR SEQUÊNCIA COMPLETA ----
func play_sequence():
	if running_sequence:
		return
	running_sequence = true

	for msg in messages:
		await show_message(msg)

	running_sequence = false
