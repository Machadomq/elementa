extends CanvasLayer

@onready var area_label: Label = $Label

func show_area_name(name: String):
	area_label.text = name
	area_label.modulate.a = 0.0  # garante que começa invisível

	var tween = create_tween()
	tween.tween_property(area_label, "modulate:a", 1.0, 0.5) # fade in em 0.5s
	tween.tween_interval(1.5) # espera 1.5s
	tween.tween_property(area_label, "modulate:a", 0.0, 0.8) # fade out em 0.8s
