extends Label

var full_text: String = ""
var typing_speed := 0.05
var display_time := 4.0  # tempo em segundos antes do fade-out

func show_text(new_text: String):
	full_text = new_text
	text = ""
	modulate.a = 0.0  # começa invisível
	_fade_in()
	await _type_text()
	await get_tree().create_timer(display_time).timeout  # espera 7s
	_fade_out()

func _type_text() -> void:
	for i in full_text.length():
		text += full_text[i]
		await get_tree().create_timer(typing_speed).timeout

func _fade_in():
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.5)  # fade-in em 0.5s

func _fade_out():
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)  # fade-out em 0.5s
