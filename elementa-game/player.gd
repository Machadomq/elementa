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

# === Status do Player ===
var vida_maxima = 100
var vida_atual = 100
var morto = false

# === Timers internos ===
var dash_timer = 0.0
var dash_cooldown_timer = 0.0
var pode_dash = true
var pode_atacar = true
var tempo_cooldown_ataque = 0.5

# === SFX ===


func _ready():
	$CooldownAtaque.timeout.connect(_on_cooldown_ataque_timeout)
	$AnimationPlayer.animation_finished.connect(_on_animation_finished)
	
	# Conecta sinais das áreas de ataque
	$areaAtaqueChao.body_entered.connect(_on_area_ataque_body_entered)
	$areaAtaqueAr.body_entered.connect(_on_area_ataque_body_entered)

	# Desativa as áreas de ataque no início
	$areaAtaqueChao.monitoring = false
	$areaAtaqueAr.monitoring = false


func _physics_process(delta: float) -> void:
	if morto:
		return

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
			$areaAtaqueChao.monitoring = true
		else:
			ataque_aereo = true
			$AnimationPlayer.play("ataque_ar")
			$areaAtaqueAr.monitoring = true

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

	# Animações normais
	if not atacando and not dashing:
		if not is_on_floor():
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
	
	if velocity.x >= 0:
		position.x = floor(position.x + 0.5)
	else:
		position.x = ceil(position.x - 0.5)

	position.y = round(position.y)

	for platforms in get_slide_collision_count(): 
		var collision = get_slide_collision(platforms)
		if collision.get_collider().has_method("has_collided_with"):
			collision.get_collider().has_collided_with(collision,self)


# === Função de dano (só recebe dano, não causa) ===
func receive_damage(amount: int):
	if morto:
		return

	vida_atual -= amount
	print("Player recebeu ", amount, " de dano. Vida: ", vida_atual)

	if vida_atual <= 0:
		morrer()


func morrer():
	morto = true
	$AnimationPlayer.play("morte")
	print("Player morreu!")


# === Área de ataque detectando inimigos ===
func _on_area_ataque_body_entered(body):
	if morto:
		return

	# Garante que não atinge o próprio player
	if body == self:
		return

	# Só causa dano em inimigos (quando existirem)
	if body.has_method("take_damage"):
		body.take_damage(25) # valor fixo de dano


# === Eventos ===
func _on_animation_finished(anim_name):
	if anim_name in ["ataque", "ataque_ar"]:
		atacando = false
		$CooldownAtaque.start(tempo_cooldown_ataque)

		# Desativa as áreas após o ataque
		$areaAtaqueChao.monitoring = false
		$areaAtaqueAr.monitoring = false

	if anim_name == "dash":
		dashing = false
		if not is_on_floor():
			if velocity.y < 0:
				$AnimationPlayer.play("jump")
			else:
				$AnimationPlayer.play("fall")
		else:
			$AnimationPlayer.play("idle")


func _on_cooldown_ataque_timeout():
	pode_atacar = true


func _on_dialogue_box_body_entered(body: Node2D) -> void:
	pass # Replace with function body.


func _on_dialogue_box_body_exited(body: Node2D) -> void:
	pass # Replace with function body.
