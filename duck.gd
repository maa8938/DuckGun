extends Node2D


const SPEED = 1000
var moving = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var mouse_pos = get_viewport().get_mouse_position()
	# look_at(mouse_pos) # look at changes angle to look at, mouse position is gotten through methods

	var left = position.x < mouse_pos.x
	var above = position.y < mouse_pos.y
	
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

	var area = $Area2D
	var wall = "res://wall.tscn"

	# deadzone implementation
	if not (((position.x - mouse_pos.x) ** 2 + (position.y - mouse_pos.y) ** 2)**0.5 < deadzone):
		if moving:
			position.x += delta_x
			position.y += delta_y	
		else:
			position.x -= delta_x
			position.y -= delta_y
			moving = true

func _on_body_entered(body: Node2D) -> void:
	print("not moving")
	moving = false
