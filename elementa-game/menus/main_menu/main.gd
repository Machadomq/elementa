extends Node

# --- Variáveis para Mute ---
# Índice do bus "Master" (é 0 por padrão, mas buscamos para segurança)
const MASTER_BUS_INDEX: int = 0

# Rastreia o estado atual (mutado ou não)
var is_muted: bool = false 

# Armazena o volume original antes de mutar (para restaurar)
var original_volume_db: float = 0.0 
# ---------------------------

## script menu principal

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://cenas/Interactions/intro.tscn")


##func _on_credit_button_pressed() -> void:
	##get_tree().change_scene_to_file("res://menus/main_menu/submenus/credits_menu/credits.tscn")


##func _on_config_button_pressed() -> void:
	##get_tree().change_scene_to_file("res://menus/main_menu/submenus/config_menu/config.tscn")


func _on_exit_button_pressed() -> void:
	get_tree().quit()


func _on_mute_button_pressed() -> void:
	is_muted = !is_muted # Alterna o estado (True <-> False)
	
	if is_muted:
		# 1. Salva o volume atual do Master Bus
		original_volume_db = AudioServer.get_bus_volume_db(MASTER_BUS_INDEX)
		
		# 2. Muta: Define o volume para o mínimo (-80 dB é o 'silêncio absoluto')
		AudioServer.set_bus_volume_db(MASTER_BUS_INDEX, -80.0)
		
		print("Áudio Global Mutado.")
	else:
		# 1. Desmuta: Restaura o volume original salvo
		AudioServer.set_bus_volume_db(MASTER_BUS_INDEX, original_volume_db)
		
		print("Áudio Global Restaurado.")
