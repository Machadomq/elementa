extends AnimatedSprite2D

# Não precisa mover o RunSprite, ele vai seguir o CharacterBody2D

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	# Atualiza a direção da sprite baseado na entrada do jogador
	if Input.is_action_pressed("ui_right"):
		flip_h = false  # Correndo para direita (normal)
	elif Input.is_action_pressed("ui_left"):
		flip_h = true   # Correndo para esquerda (espelhado)
