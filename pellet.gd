extends Node2D

var theta

const SPEED = 500

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func Pellet(pos: Vector2, t):
	theta = t
	position = pos

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var delta_x = cos(theta) * SPEED * delta
	var delta_y = sin(theta) * SPEED * delta
	
	position.x += delta_x
	position.y += delta_y
