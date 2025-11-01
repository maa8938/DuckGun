extends Node2D


const SPEED = 1000

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var mouse_pos = get_viewport().get_mouse_position()
	#look_at(mouse_pos) # look at changes angle to look at, mouse position is gotten through methods

	var left = position.x < mouse_pos.x
	var above = position.y < mouse_pos.y
	
	var x = abs(position.x - mouse_pos.x)
	var y = abs(position.y - mouse_pos.y)
	
	var theta = atan(y/x)
	
	var delta_x = cos(theta) * SPEED * delta
	var delta_y = sin(theta) * SPEED * delta
	
	if not left:
		delta_x *= -1
	
	if not above:
		delta_y *= -1
	
	position.x += delta_x
	position.y += delta_y
	
	
	
	
	
	
