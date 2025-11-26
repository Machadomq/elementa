extends Node

@onready var Menubutton = $Menubutton as AudioStreamPlayer

## script menu principal

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://levels/world_02.tscn")
	Menubutton.play()


func _on_credit_button_pressed() -> void:
	get_tree().change_scene_to_file("res://menus/main_menu/submenus/credits_menu/credits.tscn")
	Menubutton.play()


func _on_config_button_pressed() -> void:
	get_tree().change_scene_to_file("res://menus/main_menu/submenus/config_menu/config.tscn")
	Menubutton.play()


func _on_exit_button_pressed() -> void:
	get_tree().quit()
	Menubutton.play()
