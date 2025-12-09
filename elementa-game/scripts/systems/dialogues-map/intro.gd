extends Node2D 

# ====================================================================
# REFERÊNCIAS E CONSTANTES
# ====================================================================

@onready var historia_label: Label = $CanvasLayer/ColorRect/Label
@onready var fundo: ColorRect = $CanvasLayer/ColorRect

const CENA_PRINCIPAL: String = "res://levels/world_02.tscn"

# DADOS DA HISTÓRIA
const HISTORIA_LINHAS: Array[String] = [
	"Marie trabalhava tarde no laboratório, investigando novos sais de rádio.",
	"Buscava compreender por que certos compostos liberavam energia além do esperado.",
	"Durante um experimento, uma amostra instável começou a emitir luz intensa.",
	"Um pulso de radiação súbito — muito acima do normal — tomou a sala.",
	"A energia liberada reuniu-se em um ponto, como se dobrasse o próprio espaço.",
	"Antes que pudesse reagir, a explosão silenciosa puxou Marie para o centro.",
	"O laboratório desapareceu.",
	"Num instante, ela atravessou algo que não deveria existir: um rasgo na realidade.",
	"Quando a luz se dissipou, Marie já não estava mais em seu mundo.",
	"Era o começo de um destino que ela jamais imaginou."
]


# CITAÇÃO FINAL
const FRASE_MARIE_CURIE: String = "Nada na vida deve ser temido, somente compreendido.\nAgora é hora de compreender mais para temer menos.\n\n- Marie Curie (1867-1934)"

# VARIÁVEIS DE TIMING E EFEITO
const TYPING_SPEED := 0.04 # Velocidade da digitação
const DELAY_ENTRE_LINHAS_EXIBICAO: float = 2.0 # Tempo que o texto fica parado
const DELAY_FADE: float = 0.3 # Tempo de fade-in e fade-out (usado apenas na citação)

var indice_linha_atual: int = 0
var has_shown_final_quote: bool = false # Flag para controlar a citação final


# ====================================================================
# INICIALIZAÇÃO
# ====================================================================

func _ready() -> void:
	historia_label.text = "" 
	
	# 1. Fade in do fundo da tela
	fundo.modulate.a = 0.0
	var tween_fundo = create_tween()
	tween_fundo.tween_property(fundo, "modulate:a", 1.0, 1.0)
	
	await tween_fundo.finished 
	
	# Garante que o Label esteja totalmente visível para a digitação
	historia_label.modulate.a = 1.0 
	
	_iniciar_ciclo_historia()
	


# ====================================================================
# LÓGICA DE REVELAÇÃO SEQUENCIAL (CORRIGIDA)
# ====================================================================

func _iniciar_ciclo_historia() -> void:
	if indice_linha_atual < HISTORIA_LINHAS.size():
		
		var linha_completa = HISTORIA_LINHAS[indice_linha_atual]
		
		# 🚨 FIX: NÃO CHAMAR O FADE AQUI! O texto é apenas adicionado abaixo.
		
		# 1. Revela a nova linha com a máquina de escrever
		await _mostrar_linha_atual(linha_completa)
		
		# 2. Espera o tempo de exibição 
		await get_tree().create_timer(DELAY_ENTRE_LINHAS_EXIBICAO).timeout
		
		indice_linha_atual += 1
		_iniciar_ciclo_historia() # Chama a próxima linha
		
	elif not has_shown_final_quote: 
		# 🚨 AQUI ONDE O FADE É NECESSÁRIO!
		await _mostrar_frase_final()
		
	else:
		# Fim de tudo: avança para a próxima cena
		_transicionar_para_jogo()


func _mostrar_frase_final() -> void:
	has_shown_final_quote = true
	
	# 1. FADE-OUT DO TEXTO DA HISTÓRIA
	await _fade_out_texto()
	
	# 2. Revela a frase de Marie Curie (com fade-in e máquina de escrever)
	await _mostrar_linha_atual_final(FRASE_MARIE_CURIE)
	
	# 3. Tempo extra para leitura
	await get_tree().create_timer(DELAY_ENTRE_LINHAS_EXIBICAO * 2.5).timeout 
	
	# 4. Continua o fluxo para a transição
	_iniciar_ciclo_historia() 


# ====================================================================
# EFEITOS E MÁQUINA DE ESCREVER
# ====================================================================

# 🚨 FUNÇÃO RESTAURADA: APENAS ADICIONA TEXTO, SEM FADE
func _mostrar_linha_atual(nova_linha: String) -> void:
	var texto_anterior = historia_label.text
	var prefixo = ""
	
	# Adiciona prefixo de quebra de linha, exceto se for o primeiro texto
	if not texto_anterior.is_empty():
		prefixo = "\n"

	# Prepara o Label para o início da digitação
	historia_label.text = texto_anterior + prefixo
	
	# Digita a nova linha, caractere por caractere
	for i in nova_linha.length():
		historia_label.text += nova_linha[i]
		await get_tree().create_timer(TYPING_SPEED).timeout
		
		
# 🚨 NOVA FUNÇÃO: USADA APENAS PARA A FRASE FINAL (COM FADE-IN)
func _mostrar_linha_atual_final(nova_linha: String) -> void:
	
	# 1. Faz o fade-in ANTES de começar a digitar
	historia_label.modulate.a = 0.0
	var tween_fade_in = create_tween()
	tween_fade_in.tween_property(historia_label, "modulate:a", 1.0, DELAY_FADE)
	
	await tween_fade_in.finished
	
	# 2. Digita a nova linha (o texto já está limpo de _fade_out_texto)
	historia_label.text = "" 
	
	for i in nova_linha.length():
		historia_label.text += nova_linha[i]
		await get_tree().create_timer(TYPING_SPEED).timeout


# USADA APENAS PARA FAZER O FADE-OUT DA HISTÓRIA ANTES DA CITAÇÃO FINAL
func _fade_out_texto() -> void:
	var tween = create_tween()
	tween.tween_property(historia_label, "modulate:a", 0.0, DELAY_FADE)
	await tween.finished
	
	# Limpa o texto e prepara o Label para o próximo fade-in/digitação
	historia_label.text = "" 
	historia_label.modulate.a = 1.0 


# ... (O restante das funções _transicionar_para_jogo, etc. permanecem as mesmas) ...
func _transicionar_para_jogo() -> void:
	# Fade-out suave da tela antes de trocar a cena
	var tween_transicao = create_tween()
	tween_transicao.tween_property(fundo, "modulate:a", 0.0, 1.0)
	
	await tween_transicao.finished
	get_tree().change_scene_to_file(CENA_PRINCIPAL)
