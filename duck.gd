extends Node2D


const SPEED = 100

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var mouse_pos = get_viewport().get_mouse_position()
	#look_at(mouse_pos) # look at changes angle to look at, mouse position is gotten through methods
	
	var delta_x = position.x - mouse_pos.x
	var delta_y = position.y - mouse_pos.y
	
	
	var left = position.x < mouse_pos.x
	var above = position.y < mouse_pos.y
	
	var x_s = (SPEED*SPEED - delta_x*delta_x)**0.5 * delta
	var y_s = (SPEED*SPEED - delta_y*delta_y)**0.5 * delta
	
	if left:
		position.x += x_s
	else:
		position.x -= x_s
	if above:
		position.y += y_s
	else:
		position.y -= y_s
	
	
	
	
