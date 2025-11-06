extends CharacterBody2D

@export var speed: float = 80.0                # Velocidade do inimigo
@export var detection_radius: float = 200.0    # Raio onde começa a seguir o player
@export var stop_radius: float = 300.0         # Distância onde para de seguir e volta
@export var return_speed: float = 60.0         # Velocidade ao retornar à posição inicial

var player: Node2D
var following := false
var start_position: Vector2

func _ready():
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

func _physics_process(delta):
	if player == null:
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
