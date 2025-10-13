extends CharacterBody2D

# === Constantes ===
const SPEED = 150.0
const JUMP_VELOCITY = -300.0
const AIR_ATTACK_PUSH = 50.0
const DASH_SPEED = 400.0
const DASH_TIME = 0.2
const DASH_COOLDOWN = 1.0

# === Estado do Player ===
var atacando = false
var ataque_aereo = false
var dashing = false
var olhando_para_esquerda = false
var pulo_extra_disponivel = true

# === Timers internos ===
var dash_timer = 0.0
var dash_cooldown_timer = 0.0
var pode_dash = true
var pode_atacar = true
var tempo_cooldown_ataque = 0.5

func _ready():
	$CooldownAtaque.timeout.connect(_on_cooldown_ataque_timeout)
	$AnimationPlayer.animation_finished.connect(_on_animation_finished)

func _physics_process(delta: float) -> void:
	# Atualiza dash e cooldown
	if dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			dashing = false

	if not pode_dash:
		dash_cooldown_timer -= delta
		if dash_cooldown_timer <= 0:
			pode_dash = true

	# Gravidade (não aplica durante dash)
	if not is_on_floor() and not dashing:
		velocity += get_gravity() * delta
	elif is_on_floor():
		pulo_extra_disponivel = true  # reseta double jump

	# Movimento horizontal
	var direction := Input.get_axis("ui_left", "ui_right")
	if not dashing:
		if direction:
			velocity.x = direction * SPEED
			$Sprite.flip_h = direction < 0
			olhando_para_esquerda = direction < 0
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

	# Pulo / double jump
	if Input.is_action_just_pressed("ui_accept"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
			$AnimationPlayer.play("jump")
		elif pulo_extra_disponivel:
			velocity.y = JUMP_VELOCITY
			$AnimationPlayer.play("jump")
			pulo_extra_disponivel = false

	# Ataque
	if Input.is_action_just_pressed("ataque") and pode_atacar:
		atacando = true
		pode_atacar = false

		if is_on_floor():
			ataque_aereo = false
			$AnimationPlayer.play("ataque")
		else:
			ataque_aereo = true
			$AnimationPlayer.play("ataque_ar")
			if olhando_para_esquerda:
				velocity.x -= AIR_ATTACK_PUSH
			else:
				velocity.x += AIR_ATTACK_PUSH

		$Sprite.flip_h = olhando_para_esquerda
		return

	# Dash
	if Input.is_action_just_pressed("dash") and not dashing and pode_dash and not atacando:
		dashing = true
		dash_timer = DASH_TIME
		pode_dash = false
		dash_cooldown_timer = DASH_COOLDOWN
		$AnimationPlayer.play("dash")
		if olhando_para_esquerda:
			velocity.x = -DASH_SPEED
		else:
			velocity.x = DASH_SPEED
		return

	# Animações normais (se não estiver atacando ou dash)
	if not atacando and not dashing:
		if not is_on_floor():
			# Espelhamento no ar
			if direction != 0:
				$Sprite.flip_h = direction < 0
				olhando_para_esquerda = direction < 0

			if velocity.y < 0:
				$AnimationPlayer.play("jump")
			else:
				$AnimationPlayer.play("fall")
		else:
			if direction != 0:
				$AnimationPlayer.play("run")
			else:
				$AnimationPlayer.play("idle")

# === Eventos ===
func _on_animation_finished(anim_name):
	if anim_name in ["ataque", "ataque_ar"]:
		atacando = false
		$CooldownAtaque.start(tempo_cooldown_ataque)

	if anim_name == "dash":
		dashing = false
		# volta para a animação adequada
		if not is_on_floor():
			if velocity.y < 0:
				$AnimationPlayer.play("jump")
			else:
				$AnimationPlayer.play("fall")
		else:
			$AnimationPlayer.play("idle")

func _on_cooldown_ataque_timeout():
	pode_atacar = true
