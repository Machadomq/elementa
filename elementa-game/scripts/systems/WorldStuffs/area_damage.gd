extends Area2D

@export var damage: int = 10  # Dano a ser causado.
@export var attack_cooldown: float = 1.0  # Tempo de espera (cooldown) entre ataques em segundos.

var is_player_in_area: bool = false
var player_node: Node2D = null
var _attack_timer: Timer

func _ready() -> void:
	# Cria o Timer para controlar o cooldown de ataque
	_attack_timer = Timer.new()
	add_child(_attack_timer)
	# Conecta o sinal 'timeout' do Timer para o método de ataque
	_attack_timer.connect("timeout", _on_attack_timer_timeout)
	_attack_timer.wait_time = attack_cooldown
	_attack_timer.one_shot = true
	# Certifique-se de que os sinais da Area2D estão conectados no editor (ou via código)
	# connect("body_entered", _on_body_entered)
	# connect("body_exited", _on_body_exited)

# --- Métodos de Sinal da Area2D ---

func _on_body_entered(body: Node2D) -> void:
	# Tentativa de identificar o Player (Ajuste a checagem conforme a estrutura do seu jogo)
	if body.name == "Player" or body.has_method("receive_damage"): # Exemplo de verificação
		player_node = body
		is_player_in_area = true
		
		# Inicia o ataque imediatamente
		_on_attack_timer_timeout()
		
		# Inicia o Timer para ataques subsequentes (automação do cooldown)
		if not _attack_timer.is_stopped():
			_attack_timer.stop() # Garante que está parado antes de reiniciar
		_attack_timer.start()

func _on_body_exited(body: Node2D) -> void:
	if body == player_node:
		is_player_in_area = false
		player_node = null
		# Para o timer de ataque quando o jogador sai da área
		_attack_timer.stop()

# --- Lógica de Ataque ---

# Este método é chamado imediatamente na entrada e toda vez que o Timer chega ao fim.
func _on_attack_timer_timeout() -> void:
	if not is_player_in_area or player_node == null:
		return

	# Checagem de vida/morte (se o Player tiver este método)
	if player_node.has_method("is_dead") and player_node.is_dead():
		return

	# Aplica o dano
	if player_node.has_method("receive_damage"):
		player_node.receive_damage(damage, self)
		print("👾 Inimigo causou ", damage, " de dano em ", player_node.name)
	
	# Reinicia o Timer SE o player ainda estiver na área
	if is_player_in_area:
		_attack_timer.start()
