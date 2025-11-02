extends Node2D

var theta
var delta_x = 0
var delta_y = 0
var life_time_end = 0.75
var life_time = 0
const SPEED = 15/2

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
	life_time += delta
	position.x += delta_x * delta * SPEED
	position.y += delta_y * delta * SPEED
	if life_time >= life_time_end:
		queue_free()


func _on_area_2d_area_entered(area: Area2D) -> void:
	var parent = area.get_parent()
	var type = parent.get_class()
	print(type)
	if type == "CharacterBody2D":
		area.get_parent().hurt()
	queue_free()
	
