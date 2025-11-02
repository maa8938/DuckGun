extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Gameplay.process_mode = Node.PROCESS_MODE_DISABLED
	#position.x = get_viewport().size.x / 2
	#position.y = get_viewport().size.y / 2
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_duck_died() -> void:
	get_node("Gameplay").visible = false
	get_node("Loss Screen").visible = true
	print("IM DEAD")


func _on_button_pressed() -> void:
	$Gameplay.process_mode = Node.PROCESS_MODE_INHERIT
	$Gameplay.show()
	get_tree().queue_delete($Startmenu)
	pass # Replace with function body.
