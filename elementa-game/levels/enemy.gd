extends CharacterBody2D

@export var speed: float = 80.0                # Velocidade do inimigo
@export var detection_radius: float = 200.0    # Raio onde começa a seguir o player
@export var stop_radius: float = 300.0         # Distância onde para de seguir e volta
@export var return_speed: float = 60.0         # Velocidade ao retornar à posição inicial
@export var damage: int = 10                   # Dano causado ao encostar no player via Area2D
@export var attack_cooldown: float = 0.8       # Tempo entre danos sucessivos
@export var knockback_force: float = 600.0      # Força horizontal do knockback recebido
@export var knockback_up: float = -200.0        # Impulso vertical ao receber dano
@export var knockback_duration: float = 0.5    # Duração do efeito de knockback
@export var knockback_damp: float = 1200.0      # Fator de amortecimento horizontal

var player: Node2D
var following := false
var start_position: Vector2
var can_attack := true
var _damage_cd_timer: Timer
var being_knocked_back: bool = false
var knockback_timer: float = 0.0

func _ready():
	
	set_collision_mask_value(3, false) # não colide com layer 3 (player)
	
	# Salva o ponto inicial
	start_position = global_position
	
	# Tenta achar o player na cena (atenção: nome do nó é "Player", com P maiúsculo)
	player = get_tree().current_scene.get_node_or_null("player")
	
	if player == null:
		player = get_tree().current_scene.find_child("player", true, false)
	
	if player == null:
		print("⚠️ Player não encontrado, verifique o nome do nó.")
	else:
		print("✅ Player encontrado: ", player.name)

	# Conecta sinais da Area2D (dano por contato)
	if has_node("Area2D"):
		var area := $Area2D as Area2D
		# Garante que a máscara da área inclui as mesmas camadas do player
		if player:
			# Em Godot 4, CharacterBody2D possui propriedade collision_layer
			area.collision_mask = player.collision_layer
		# Conecta o sinal de entrada de corpo
		area.body_entered.connect(_on_area2d_body_entered)
	else:
		print("ℹ️ Nenhuma Area2D encontrada como filha do inimigo.")

	# Cria timer de cooldown para não causar dano a cada frame
	_damage_cd_timer = Timer.new()
	_damage_cd_timer.one_shot = true
	_damage_cd_timer.wait_time = attack_cooldown
	_damage_cd_timer.timeout.connect(func(): can_attack = true)
	add_child(_damage_cd_timer)

func _physics_process(delta):
	if player == null:
		return

	# Se o player estiver morto, parar de seguir e retornar à posição inicial
	if player.has_method("is_dead") and player.is_dead():
		following = false
		var distance_to_start_dead = global_position.distance_to(start_position)
		if distance_to_start_dead > 5:
			move_towards(start_position, return_speed)
		else:
			velocity = Vector2.ZERO
			move_and_slide()
		return

	# Atualiza knockback quando ativo (prioritário sobre perseguir)
	if being_knocked_back:
		knockback_timer -= delta
		# Aplica gravidade enquanto no ar (se houver)
		if not is_on_floor():
			velocity += get_gravity() * delta
		# Suaviza horizontal
		velocity.x = move_toward(velocity.x, 0.0, knockback_damp * delta)
		if knockback_timer <= 0.0 or abs(velocity.x) < 5.0:
			being_knocked_back = false
		move_and_slide()
		return

	var distance_to_player = global_position.distance_to(player.global_position)
	
	# Verifica se deve seguir ou desistir
	if distance_to_player < detection_radius:
		following = true
	elif distance_to_player > stop_radius:
		following = false

	if following:
		move_towards(player.global_position, speed)
	else:
		# Se não está seguindo, retorna à posição original
		var distance_to_start = global_position.distance_to(start_position)
		if distance_to_start > 5:  # margem de erro
			move_towards(start_position, return_speed)
		else:
			velocity = Vector2.ZERO
			move_and_slide()

func move_towards(target_position: Vector2, move_speed: float):
	var direction = (target_position - global_position).normalized()
	velocity = direction * move_speed
	move_and_slide() 

# === Dano por contato via Area2D ===
func _on_area2d_body_entered(body: Node) -> void:
	if not can_attack:
		return

	# Evita causar dano se o player estiver morto
	if player and player.has_method("is_dead") and player.is_dead():
		return

	# Garante que é o player e que ele pode receber dano
	var is_player := (player != null and body == player)
	if is_player:
		player.receive_damage(damage, self)
		print("👾 Inimigo causou ", damage, " de dano em ", player.name)
	elif body.has_method("receive_damage"):
		body.receive_damage(damage, self)
		print("👾 Inimigo causou ", damage, " de dano em ", body.name)
	can_attack = false
	_damage_cd_timer.start()

# === Receber dano de ataques do player (extra útil para debug) ===
var health: int = 40

func take_damage(amount: int) -> void:
	health -= amount
	# Aplica knockback ao receber dano (usa posição relativa ao player se existir)
	var dir := 0.0
	if player:
		dir = sign(global_position.x - player.global_position.x)
	else:
		dir = sign(velocity.x) if velocity.x != 0 else 1.0

	being_knocked_back = true
	knockback_timer = knockback_duration
	velocity.x = lerp(velocity.x, dir * knockback_force, 0.6)
	velocity.y = min(velocity.y, knockback_up)  # aplica impulso vertical se estiver subindo menos

	print("🩸 Inimigo recebeu ", amount, " de dano. Vida: ", health, " | Knockback dir=", dir)
	if health <= 0:
		print("💀 Inimigo derrotado (removendo da cena)")
		queue_free()
