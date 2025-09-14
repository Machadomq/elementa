extends Area2D

@export var next_level : String = ""
@export var transition_controller : CanvasLayer
@onready var transition_animator = transition_controller.get_node("anim")


func _ready() -> void: 
	self.body_entered.connect(_on_body_entered)
	
	
func _on_body_entered(body: Node2D): 
	if body.name == "player":
		transition_animator.play("fade_in")
		await transition_animator.animation_finished
		Global.destination_level = get_parent().name
		get_tree().call_deferred("change_scene_to_file", next_level)
