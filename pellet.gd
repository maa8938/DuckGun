extends Node2D

var theta
var x_mult = 1
var y_mult = 1

const SPEED = 500

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func Pellet(pos: Vector2, mouse_pos):
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var delta_x = cos(theta) * SPEED * delta * x_mult
	var delta_y = sin(theta) * SPEED * delta * y_mult
	
	position.x += delta_x
	position.y += delta_y
