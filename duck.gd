extends Node2D

var moving = true
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
	var deadzone = 10
	var delta_x = cos(current_theta) * SPEED * delta
	var delta_y = sin(current_theta) * SPEED * delta
	
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
	
	if not left and above:
		quadrant = Globals.Q1
	elif left and above:
		quadrant = Globals.Q2
	elif left and not above:
		quadrant = Globals.Q3
	elif not left and not above:
		quadrant = Globals.Q4
		
	position.x += delta_x
	position.y += delta_y
	
	

func blast():
	var pellet = PELLET.instantiate()
	pellet.Pellet(position, current_theta, quadrant)
	get_tree().current_scene.add_child(pellet)
	print(get_parent().get_tree_string_pretty())

func _on_body_entered(body: Node2D) -> void:
	print("not moving")
	moving = false
	
func _input(event: InputEvent) -> void:
	if event.is_action_released("left_click"):
		#blast()
		print("blast")
