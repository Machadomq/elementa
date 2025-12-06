extends Node2D

@onready var wall = $Wall
@onready var trigger_area = $trigger 
@onready var alavanca = $alavanca
# Já estão corretos, assumindo a estrutura $Wall/wall_animated, $Wall/wall_collision
@onready var wall_animated: AnimatedSprite2D = $Wall/wall_animated 
@onready var wall_collision: CollisionShape2D = $Wall/wall_collision 

var player_in_area: bool = false
var is_solved: bool = false 
var resposta: bool = false

func _ready() -> void:
	wall_animated.play('fire')

# ... (Funções _on_trigger_body_entered e _on_trigger_body_exited permanecem as mesmas) ...


func _on_dialogic_signal(arg: String): 
	if arg == "teste1":
		resposta = true
		print("resposta certa")
		solve_puzzle()
	else: 
		pass

func _on_trigger_body_entered(body: Node2D) -> void:
	if body.name == "player":
		player_in_area = true
		print("Pressione INTERACT para acionar.")


func _on_trigger_body_exited(body: Node2D) -> void:

	if body.name == "player":

		player_in_area = false


# ... (Função _process permanece a mesma) ...


func _process(_delta: float) -> void:
	if player_in_area and not is_solved and Input.is_action_just_pressed("INTERACT"):
		Dialogic.signal_event.connect(_on_dialogic_signal)
		Dialogic.start("teste1")

# Não é necessário set_input_as_handled() em _process

# ====================================================================
# LÓGICA DE INTERAÇÃO E ATIVAÇÃO (RESOLUÇÃO DO PUZZLE)
# ====================================================================

func solve_puzzle() -> void:
	# 1. Trava o puzzle
	is_solved = true
	print("Puzzle Resolvido! Iniciando animação de abertura.")
	alavanca.play("ativa2")
	
	if is_instance_valid(wall_animated):
		wall_animated.play("closing")
		_on_wall_animated_animation_finished()



func _on_wall_animated_animation_finished() -> void:
		if is_instance_valid(wall_collision):
			# AÇÃO PRINCIPAL: Desabilita a colisão
			wall_collision.set_deferred("disabled", true)
			print("Colisão da parede desabilitada. Caminho livre!")
		
