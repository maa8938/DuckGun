extends Node2D

enum{Q1, Q2, Q3, Q4}

const SPEED = 250
var current_theta = -1
var quadrant
@onready var PELLET = preload("res://pellet.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var mouse_pos = get_viewport().get_mouse_position()
	look_at(mouse_pos) # look at changes angle to look at, mouse position is gotten through methods

	var left = position.x < mouse_pos.x
	var above = position.y < mouse_pos.y
	
	var x = abs(position.x - mouse_pos.x)
	var y = abs(position.y - mouse_pos.y)
	
	var current_theta = atan(y/x)
	
	var delta_x = cos(current_theta) * SPEED * delta
	var delta_y = sin(current_theta) * SPEED * delta
	
	if left and above:
	
	
	
	position.x += delta_x
	position.y += delta_y
	
	

func blast():
	var pellet = PELLET.instantiate()
	pellet.Pellet(position, current_theta)
	get_tree().current_scene.add_child(pellet)
	print(get_parent().get_tree_string_pretty())

	
func _input(event: InputEvent) -> void:
	if event.is_action_released("left_click"):
		blast()
	
	
	
	
