extends CharacterBody2D

const SPEED = 150.0
const JUMP_VELOCITY = -300.0

func _physics_process(delta: float) -> void:
	# Adiciona gravidade
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Pulo
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Direção do movimento
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

	# Atualização das sprites
	if not is_on_floor():
		# No ar -> sprite de pulo
		$RunSprite.visible = false
		$JumpSprite.visible = true
		$JumpSprite.play("jump")  # Certifique-se que a animação se chama "jump"
	else:
		# No chão -> sprite de correr
		$JumpSprite.visible = false
		$RunSprite.visible = true
		
		# Direção da sprite de corrida
		if direction != 0:
			$RunSprite.flip_h = direction < 0
			$RunSprite.play("anim")  # Certifique-se que a animação se chama "run"
		else:
			$RunSprite.play("idle")  # Opcional: animação parado
