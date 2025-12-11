extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
##func _process(delta: float) -> void:
	##pass


func _on_restart_btn_pressed() -> void:
	get_tree().paused = false
	queue_free()
	get_tree().change_scene_to_file("res://levels/world_02.tscn")
	Global.current_health = Global.max_health
	
	
func _on_quit_btn_pressed() -> void:
	get_tree().paused = false
	queue_free()
	get_tree().change_scene_to_file("res://menus/main_menu/main.tscn")
	
