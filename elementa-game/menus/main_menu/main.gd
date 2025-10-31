extends Node

## script menu principal

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://levels/world_02.tscn")


func _on_credit_button_pressed() -> void:
	get_tree().change_scene_to_file("res://menus/main_menu/submenus/credits_menu/credits.tscn")


func _on_config_button_pressed() -> void:
	get_tree().change_scene_to_file("res://menus/main_menu/submenus/config_menu/config.tscn")


func _on_exit_button_pressed() -> void:
	get_tree().quit()
