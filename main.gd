extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_duck_died() -> void:
	get_node("Gameplay").visible = false
	get_node("Loss Screen").visible = true
	print("IM DEAD")

func _on_duck_win() -> void:
	get_node("Gameplay").visible = false
	get_node("Win Screen").visible = true
	
