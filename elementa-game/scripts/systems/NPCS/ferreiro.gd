extends Area2D

@onready var label_interacao = $Sprite2D2 # Label de interação (seu sprite original)
@onready var animated = $animated          # Sprite/Player de animação (arriving/idle/talking)
@onready var tween := create_tween()       # Tween para controlar as transições
@onready var player = get_tree().get_root().find_child("player", true, false)


var player_in_area = false
var dialog_active = false

# --- Configuração Inicial ---

func _ready() -> void:
	# Configurações de visibilidade inicial
	label_interacao.visible = false
	label_interacao.modulate.a = 0.0 # Começa invisível    # Começa invisível
	
	# Conexões dos Sinais
	if animated.has_signal("animation_finished"):
		animated.animation_finished.connect(_on_animated_animation_finished)
	
	Dialogic.timeline_ended.connect(_on_dialogic_timeline_ended)


# --- Controle de Área ---

func _on_body_entered(body) -> void:
	if body.name == "player": 
		player_in_area = true
		
		# 1. Faz o fade-in dos elementos
		_show_interaction_elements()
		
		# 2. Inicia a animação de entrada (deve fazer a transição para idle)
		animated.play("idle")


func _on_body_exited(body) -> void:
	if body.name == "player":
		player_in_area = false
		_hide_interaction_elements()
		animated.play("idle")
		# 2. Fecha o diálogo automaticamente
		if dialog_active:
			Dialogic.end_timeline() 
			dialog_active = false
			
		# 3. Para a animação 


# --- Controle de Animação de Entrada/Saída ---

# Chamada quando a animação do AnimatedSprite2D/AnimationPlayer termina.
func _on_animated_animation_finished(anim_name: StringName) -> void:
	# Só transiciona para idle se a animação que terminou foi a 'arriving'
	if anim_name == "arriving":
		animated.play("idle")


# --- FUNÇÕES DE FADE IN/OUT (TWEEN) ---

# Fade in
func _show_interaction_elements() -> void:
	# Torna visível primeiro, depois anima a transparência
	label_interacao.visible = true
	
	tween.kill()
	tween = create_tween()
	
	# Anima o Label para 100% de opacidade
	tween.tween_property(label_interacao, "modulate:a", 1.0, 0.2)
	# Anima o AnimatedSprite/Player para 100% de opacidade


# Fade out
func _hide_interaction_elements() -> void:
	tween.kill()
	tween = create_tween()
	
	# Anima o Label para 0% de opacidade
	tween.tween_property(label_interacao, "modulate:a", 0.0, 0.3)
	# Anima o AnimatedSprite/Player para 0% de opacidade
	
	# Espera o tween terminar para esconder os elementos de forma limpa
	await tween.finished
	label_interacao.visible = false


# --- PROCESSO DE INTERAÇÃO E DIÁLOGO ---

func _process(delta) -> void:
	if player_in_area \
	and not dialog_active \
	and Input.is_action_just_pressed("INTERACT"):

		dialog_active = true

		var npc_key = "ferreiro_first_interact"
			
		if Global.npc_states[npc_key] == false:
			Dialogic.start("ferreiro")
			Global.npc_states[npc_key] = true
		else:
			var current_element = Global.coins
				# Assumimos que 'player' foi referenciado corretamente no script
				
				# --- LÓGICA DE UPGRADE COM TRAVAMENTO (BLOQUEIO DE REPETIÇÃO) ---
				
				# Tier 1: Elementos 13 a 25 E NÃO FOI FEITO AINDA
			if current_element >= 13 and current_element <= 25 and not Global.npc_states["upgrade_tier_1_done"]:
				player._upgradePower()
				Global.npc_states["upgrade_tier_1_done"] = true # 🚨 MARCA COMO CONCLUÍDO
				
						
					# Tier 2: Elementos 26 a 46 E NÃO FOI FEITO AINDA
			elif current_element >= 26 and current_element <= 46 and not Global.npc_states["upgrade_tier_2_done"]:
				player._upgradePower()
				Global.npc_states["upgrade_tier_2_done"] = true # 🚨 MARCA COMO CONCLUÍDO
				
						
					# Tier 3: Elementos acima de 46 E NÃO FOI FEITO AINDA
			elif current_element > 46 and not Global.npc_states["upgrade_tier_3_done"]:
				player._upgradePower()
				Global.npc_states["upgrade_tier_3_done"] = true # 🚨 MARCA COMO CONCLUÍDO
						
			else:
				Dialogic.start('alquimista_no_upgrade') # Crie um diálogo genérico de "Nada de novo"
				pass

		animated.play("dialog")
		

# Chamada quando o Dialogic finaliza a "timeline".
func _on_dialogic_timeline_ended() -> void:
	dialog_active = false
	
	# Volta para a animação "idle", se o player ainda estiver na área
	if player_in_area:
		animated.play("idle")
	else:
		animated.play("work")


func _on_animated_sprite_2d_animation_finished() -> void:
	pass # Replace with function body.
