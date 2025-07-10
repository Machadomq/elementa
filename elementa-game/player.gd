extends CharacterBody2D

const SPEED = 150.0
const JUMP_VELOCITY = -300.0

var atacando = false
var pode_atacar = true
var tempo_cooldown_ataque = 0.5
var olhando_para_esquerda = false
var testeCarga= false
var testeCarga2=false

func _ready():
	$ataque.animation_finished.connect(_on_ataque_animation_finished)
	$CooldownAtaque.timeout.connect(_on_cooldown_ataque_timeout)
	$testeCarga.animation_finished.connect(_on_testeCarga_animation_finished)
	$testeCarga2.animation_finished.connect(_on_testeCarga2_animation_finished)
	
func _physics_process(delta: float) -> void:
	
	if $testeCarga2.is_playing():
		velocity.x = 0
		return
		
	if $testeCarga.is_playing():
		velocity.x = 0
		return
		
	if Input.is_action_just_pressed("testeCarga2"):
		$testeCarga2.visible=true
		$testeCarga2.play("testeCarga2")
		$RunSprite.visible = false
		$JumpSprite.visible= false
		return
		
	if Input.is_action_just_pressed("testeCarga"):
		$testeCarga.visible=true
		$testeCarga.play("testeCarga")
		$RunSprite.visible = false
		$JumpSprite.visible= false
		return
	# Bloqueia o movimento e animação se estiver atacando
	if atacando:
		velocity.x = 0
		return

	# Gravidade
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Pulo
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Movimento
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

	# Ataque com cooldown
	if Input.is_action_just_pressed("ataque") and not atacando and pode_atacar:
		atacando = true
		pode_atacar = false
		$ataque.visible = true
		$ataque.flip_h = olhando_para_esquerda
		$ataque.play("ataque")
		$RunSprite.visible = false
		$JumpSprite.visible = false
		return

	# Animações normais
	if not is_on_floor():
		$RunSprite.visible = false
		$JumpSprite.visible = true
		$JumpSprite.play("jump")
	else:
		$JumpSprite.visible = false
		$RunSprite.visible = true

		if direction != 0:
			$RunSprite.flip_h = direction < 0
			olhando_para_esquerda = direction < 0
			$RunSprite.play("anim")
		else:
			$RunSprite.play("idle")

func _on_ataque_animation_finished():
	atacando = false
	$ataque.visible = false
	$CooldownAtaque.start(tempo_cooldown_ataque)

func _on_testeCarga_animation_finished():
	testeCarga = false
	$testeCarga.visible = false
	
func _on_testeCarga2_animation_finished():
	testeCarga2 = false
	$testeCarga2.visible = false
	
func _on_cooldown_ataque_timeout():
	pode_atacar = true
	
	
