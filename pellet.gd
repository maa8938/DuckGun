extends Node2D

var theta
var dt = 0
var delta_x = 0
var delta_y = 0
const SPEED = 350

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func Pellet(pos: Vector2, pp):
	position = pos
	theta = pp[0]
	delta_x = pp[1]
	delta_y = pp[2]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:	
	dt += delta
	if dt > 1 / 60:
		dt -= 1/60
		position.x += delta_x * delta * SPEED
		position.y += delta_y * delta * SPEED


func _on_area_2d_area_entered(area: Area2D) -> void:
	pass
