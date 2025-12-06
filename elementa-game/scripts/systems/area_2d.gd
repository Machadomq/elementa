extends Area2D

@onready var label = $CanvasLayer/MarginContainer/Label

func _ready() -> void:
	label.visible = false

func _on_body_entered(body: Node2D) -> void:
	if body.name == "player":
		label.visible = true
		label.show_text("Castelo Mendeleev")
		
