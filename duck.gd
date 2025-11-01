extends Node2D


<<<<<<< HEAD
const SPEED = 1000
# var WALL = "res://wall.tscn"
=======
const SPEED = 100
>>>>>>> parent of 147cbc0 (Merge branch 'main' of https://github.com/maa8938/DuckGun)

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
	
<<<<<<< HEAD
	var x = abs(position.x - mouse_pos.x)
	var y = abs(position.y - mouse_pos.y)
	
	var theta = atan(y/x)
	
	var delta_x = cos(theta) * SPEED * delta
	var delta_y = sin(theta) * SPEED * delta
	var deadzone = 10
	
	if not left:
		delta_x *= -1
	
	if not above:
		delta_y *= -1
		
	# deadzone implementation
	var distance = ((position.x - mouse_pos.x) ** 2 + (position.y - mouse_pos.y) ** 2)**0.5
	if !(distance < deadzone):
		position.x += delta_x
		position.y += delta_y
	
	
		
	
	
=======
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
>>>>>>> parent of 147cbc0 (Merge branch 'main' of https://github.com/maa8938/DuckGun)
	
	
	
	
