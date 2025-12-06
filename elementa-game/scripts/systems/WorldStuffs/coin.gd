extends Area2D

var coins = 0
@onready var coinSprite = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if body.name == "player": 
		Global.coins += 1
		print(Global.coins)
		body._updateElement()
		body._playerUpgrade()
		queue_free()
		
		
