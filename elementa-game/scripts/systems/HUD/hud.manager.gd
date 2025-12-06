extends Control

# ==============================================================================
# 1. DECLARAÇÕES E VARIÁVEIS ON-READY
# ==============================================================================

# --- ELEMENTOS ---
# Ajuste este caminho para o seu Label que mostra o elemento
@onready var elementoCounter: Label = $container/HBoxContainer2/Label
const FADE_DURATION: float = 0.2 
const DELAY_DURATION: float = 0.05

# --- VIDA (FRASCOS) ---
# Array COMPLETO com TODOS os TextureRects dos frascos possíveis (Ex: até 10)
# Ajuste os caminhos! Se você só tem 4, remova os restantes desta lista.
@onready var flask_sprites: Array[TextureRect] = [
	$container/HBoxContainer/TextureRect2,
	$container/HBoxContainer/TextureRect3,
	$container/HBoxContainer/TextureRect4,
	$container/HBoxContainer/TextureRect5,
	$container/HBoxContainer/TextureRect6,
	$container/HBoxContainer/TextureRect7,
	
	# Adicionar mais se a vida máxima for maior que 60...
]
var last_required_flasks: int = 0

# ==============================================================================
# 2. FUNÇÃO PRINCIPAL DE INICIALIZAÇÃO
# ==============================================================================

func _ready() -> void:
	# --- Elementos (Coins) ---
	Global.element_changed.connect(_update_element_with_fade)
	_update_element_display(Global.coins) 
	elementoCounter.modulate.a = 1.0 # Garante que o texto comece visível

	# --- Vida (Frascos) 💖 ---
	# 1. Conecta para gerenciar o pool de frascos (Vida MÁXIMA)
	Global.max_health_changed.connect(_manage_max_flasks)
	_manage_max_flasks(Global.max_health) # Inicializa o pool
	
	# 2. Conecta para atualizar o estado dos frascos (Vida ATUAL)
	Global.health_changed.connect(_update_health_display)
	_update_health_display(Global.current_health) 


# ==============================================================================
# 3. LÓGICA DE VIDA MÁXIMA (Gerencia o Pool de Frascos)
# ==============================================================================

# Chamada pelo sinal Global.max_health_changed
func _manage_max_flasks(new_max_health: int) -> void:
	# Calcula quantos frascos são necessários (em incrementos de 10)
	
	var required_flasks: int = new_max_health / 10 
	
	
	for i in range(flask_sprites.size()):
		var flask = flask_sprites[i]
		
		# Mostra apenas os frascos que estão dentro do limite de vida máxima
		if i < required_flasks:
			if i >= last_required_flasks:
				# 🚨 APLICA O FADE-IN
				flask.visible = true
				flask.modulate.a = 0.0 # Começa totalmente transparente
				
				var tween = create_tween()
				# Interpola a opacidade (propriedade 'a' de modulate) de 0.0 para 1.0
				tween.tween_property(flask, "modulate:a", 1.0, FADE_DURATION * 1.5)
			else:
			# Frasco já existia, apenas garante que está visível e opaco
				flask.visible = true
				flask.modulate.a = 1.0 
				
		# 2. Lógica de Desativação (Frasco fora do limite máximo atual)
		else:
			flask.visible = false
			flask.modulate.a = 1.0 # Reseta a opacidade para que possa ter fade-in depois 

	last_required_flasks = required_flasks
# ==============================================================================
# 4. LÓGICA DE VIDA ATUAL (Mostra/Esconde Frascos)
# ==============================================================================

# Chamada pelo sinal Global.health_changed
# HUD.gd - NOVO CÓDIGO PARA A SEÇÃO 4

func _update_health_display(current_health: int) -> void:
	# Calcula quantos frascos (cheios/visíveis) a vida atual exige
	var visible_flasks: int = ceil(float(current_health) / 10.0)
	
	# Calcula quantos frascos a vida máxima permite
	var max_flasks: int = Global.max_health / 10
	
	for i in range(flask_sprites.size()):
		var flask = flask_sprites[i]
		
		# 1. Se este frasco está além da vida máxima (ex: Flask7 quando max=50), IGNORE.
		# Ele já está escondido pelo _manage_max_flasks.
		if i >= max_flasks:
			continue
		
		# 2. Se a vida atual exige que o frasco esteja CHEIO (visível)
		if i < visible_flasks:
			flask.visible = true
		else:
			# 3. Caso contrário, se a vida atual não exige este frasco (vazio)
			flask.visible = false


# ==============================================================================
# 5. LÓGICA DE ELEMENTOS (Fade e Texto)
# ==============================================================================

# Gerencia o efeito de Fade usando Tween
func _update_element_with_fade(atomic_number: int) -> void:
	var tween = create_tween()
	
	# 1. FADE OUT
	tween.tween_property(elementoCounter, "modulate:a", 0.0, FADE_DURATION)
	
	# 2. MEIO (Troca o texto enquanto invisível)
	tween.tween_callback(func(): _update_element_display(atomic_number)).set_delay(DELAY_DURATION)
	
	# 3. FADE IN
	tween.tween_property(elementoCounter, "modulate:a", 1.0, FADE_DURATION)

# Define o novo texto do elemento
func _update_element_display(atomic_number: int) -> void:
	var element_name: String
	
	if Global.ELEMENTOS.has(atomic_number):
		element_name = Global.ELEMENTOS[atomic_number]
	elif atomic_number == 0:
		element_name = Global.ELEMENTOS[0] 
	else:
		element_name = "Elemento Desconhecido (Z=" + str(atomic_number) + ")"
		
	elementoCounter.text = element_name
	
