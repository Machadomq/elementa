extends AnimatedSprite2D



func _ready() -> void:
	pass

func _process(delta: float) -> void:

	if Input.is_action_pressed("ui_right"):
		flip_h = false  
	elif Input.is_action_pressed("ui_left"):
		flip_h = true   
