extends CharacterBody2D

# === Constantes ===
const SPEED = 150.0
const JUMP_VELOCITY = -300.0
const AIR_ATTACK_PUSH = 50.0
const DASH_SPEED = 400.0
const DASH_TIME = 0.2
const DASH_COOLDOWN = 1.0
const KNOCKBACK_X = 1200.0
const KNOCKBACK_Y = -300.0
const KNOCKBACK_DURATION = 0.5
const KNOCKBACK_DAMP = 1400.0
const INVINCIBILITY_TIME = 0.6
const BASE_DAMAGE = 10

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
var elemento = ''

# === Timers internos ===
var dash_timer = 0.0
var dash_cooldown_timer = 0.0
var pode_dash = true
var pode_atacar = true
var tempo_cooldown_ataque = 0.5

# === Knockback ===
var being_knocked_back: bool = false
var knockback_timer: float = 0.0
var knockback_velocity: Vector2 = Vector2.ZERO

# === Invencibilidade ===
var invincible: bool = false
var inv_time_left: float = 0.0
var death_anim_started: bool = false

# === LEVEL UP ===
var levelup_pending = false
var levelup_playing = false


func is_dead() -> bool:
	return morto


func _ready():
	set_collision_mask_value(2, false)

	$CooldownAtaque.timeout.connect(_on_cooldown_ataque_timeout)
	$AnimationPlayer.animation_finished.connect(_on_animation_finished)
	
	$areaAtaqueChao.body_entered.connect(_on_area_ataque_body_entered)
	$areaAtaqueAr.body_entered.connect(_on_area_ataque_body_entered)

	$areaAtaqueChao.monitoring = false
	$areaAtaqueAr.monitoring = false


func _physics_process(delta: float) -> void:

	# Se a animação já está tocando: bloqueia tudo e retorna (prioridade máxima)
	if levelup_playing:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	# Se conseguiu iniciar a animação de levelup neste frame, retorna imediatamente
	if _try_play_levelup():
		# garantimos que o player pare neste frame e não execute lógica adicional
		velocity = Vector2.ZERO
		move_and_slide()
		return

	if morto:
		if not is_on_floor():
			velocity += get_gravity() * delta
		else:
			if not death_anim_started:
				if $AnimationPlayer.has_animation("death"):
					$AnimationPlayer.play("death")
				death_anim_started = true
			velocity.x = move_toward(velocity.x, 0, SPEED * delta)

		move_and_slide()
		return

	# Dash timers
	if dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			dashing = false

	if not pode_dash:
		dash_cooldown_timer -= delta
		if dash_cooldown_timer <= 0:
			pode_dash = true

	# Gravidade
	if not is_on_floor() and not dashing:
		velocity += get_gravity() * delta
	elif is_on_floor():
		pulo_extra_disponivel = true

	# Knockback suavizado
	if being_knocked_back:
		knockback_timer -= delta
		velocity.x = move_toward(velocity.x, 0.0, KNOCKBACK_DAMP * delta)
		if knockback_timer <= 0.0 or abs(velocity.x) < 5.0:
			being_knocked_back = false

	# Invencibilidade
	if invincible:
		inv_time_left -= delta
		if inv_time_left <= 0.0:
			invincible = false
			$Sprite.visible = true

	# Movimento horizontal
	var direction := Input.get_axis("ui_left", "ui_right")
	if not dashing and not being_knocked_back:
		if direction:
			velocity.x = direction * SPEED
			$Sprite.flip_h = direction < 0
			olhando_para_esquerda = direction < 0
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

	# Pulo
	if Input.is_action_just_pressed("ui_accept"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
			$AnimationPlayer.play("jump")
		elif pulo_extra_disponivel:
			velocity.y = JUMP_VELOCITY
			$AnimationPlayer.play("jump")
			pulo_extra_disponivel = false

	# Ataque
	if Input.is_action_just_pressed("ataque") and pode_atacar and not being_knocked_back:
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
	if Input.is_action_just_pressed("dash") and not dashing and pode_dash and not atacando and not being_knocked_back:
		dashing = true
		dash_timer = DASH_TIME
		pode_dash = false
		dash_cooldown_timer = DASH_COOLDOWN
		$AnimationPlayer.play("dash")
		velocity.x = -DASH_SPEED if olhando_para_esquerda else DASH_SPEED
		return

	# Animações normais
	if not atacando and not dashing and not being_knocked_back:
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

	# Arredondamento de posição
	if velocity.x >= 0:
		position.x = floor(position.x + 0.5)
	else:
		position.x = ceil(position.x - 0.5)
	position.y = round(position.y)

	for platforms in get_slide_collision_count():
		var collision = get_slide_collision(platforms)
		if collision.get_collider().has_method("has_collided_with"):
			collision.get_collider().has_collided_with(collision,self)



func receive_damage(amount: int, source: Node = null):
	if morto: return
	if invincible: return

	Global.current_health -= amount

	var dir := 0.0
	if source != null and source is Node2D:
		dir = sign(global_position.x - (source as Node2D).global_position.x)
	else:
		dir = 1.0 if olhando_para_esquerda else -1.0

	dashing = false
	if atacando: $CooldownAtaque.start(tempo_cooldown_ataque)
	atacando = false
	$areaAtaqueChao.monitoring = false
	$areaAtaqueAr.monitoring = false

	being_knocked_back = true
	knockback_timer = KNOCKBACK_DURATION
	knockback_velocity = Vector2(dir * KNOCKBACK_X, KNOCKBACK_Y)
	velocity.y = min(velocity.y, KNOCKBACK_Y)
	velocity.x = lerp(velocity.x, knockback_velocity.x, 0.5)

	if $AnimationPlayer.has_animation("knockback"):
		$AnimationPlayer.play("knockback")

	invincible = true
	inv_time_left = INVINCIBILITY_TIME

	if Global.current_health <= 0:
		morrer()


func morrer():
	if morto: return
	morto = true

	atacando = false
	dashing = false
	being_knocked_back = false
	invincible = false
	death_anim_started = false

	$areaAtaqueChao.monitoring = false
	$areaAtaqueAr.monitoring = false

	velocity.x *= 0.2


func _on_area_ataque_body_entered(body):
	if morto: return
	if body == self: return

	if body.has_method("take_damage"):
		body.take_damage(Global.max_power)


func _on_animation_finished(anim_name):
	if anim_name in ["ataque", "ataque_ar"]:
		atacando = false
		$CooldownAtaque.start(tempo_cooldown_ataque)
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

	if anim_name == "levelUP":
		# quando a animação termina, libera controle normal
		levelup_playing = false



func _on_cooldown_ataque_timeout():
	pode_atacar = true 


# ===================================================
#                SISTEMA DE LEVEL UP
# ===================================================
func _playerUpgrade() -> void:
	var current_coin = Global.coins

	if current_coin == 2 or current_coin == 10 or current_coin == 18 or current_coin == 24:
		Global.max_health += 10
		Global.current_health = Global.max_health
		print("A vida aumentou")

		# Marca para tocar animação (se no ar, espera; se no chão, toca imediamente)
		levelup_pending = true
		# levelup_playing deixamos falso; será true quando realmente começar a animação


# _try_play_levelup tenta iniciar a animação.
# Retorna true se a animação foi iniciada neste frame (para fazermos return imediato).
func _try_play_levelup() -> bool:
	if levelup_pending and not levelup_playing:
		# só toca se estiver no chão
		if is_on_floor():
			if not $AnimationPlayer.has_animation("levelUP"):
				push_warning("Animação 'levelUP' não encontrada no AnimationPlayer.")
				# limpa o pending para não ficar tentando infinitamente
				levelup_pending = false
				return false

			# inicia levelup e bloqueia input/ânim neste frame
			levelup_playing = true
			levelup_pending = false
			velocity = Vector2.ZERO
			$AnimationPlayer.stop()
			$AnimationPlayer.play("levelUP")
			print("▶ Iniciando levelUP")
			return true
	return false


func _updateElement() -> void:
	var atomic_number = Global.coins
	var new_element = Global.ELEMENTOS[atomic_number]
	self.elemento = new_element
	print(elemento)


func _upgradePower() -> void:
	Dialogic.start('ferreiroUp')
	Global.max_power += 10
	
	# Também marca pending para levelup (comportamento igual ao _playerUpgrade)
	levelup_pending = true
