extends Node2D

var dt = 0
var health = 3
const SPEED = 250
var pellet_param = []
signal attention(pos)
@onready var PELLET = preload("res://pellet.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	dt += delta
	if dt > 1 / 60:
		dt -= 1/60
		var mouse_pos = get_viewport().get_mouse_position()
		#look_at(mouse_pos) # look at changes angle to look at, mouse position is gotten through methods

		var left = position.x < mouse_pos.x
		var above = position.y < mouse_pos.y
		
		var true_x = position.x - mouse_pos.x
		var true_y = position.y - mouse_pos.y

		var x = abs(true_x)
		var y = abs(true_y)
		
		var current_theta = atan(y/x)
		
		var delta_x = cos(current_theta) * SPEED * delta
		var delta_y = sin(current_theta) * SPEED * delta

		if not left:
			delta_x *= -1
			$Area2D/AnimatedSprite2D.animation = "side"
			$Area2D/AnimatedSprite2D.play()
			$Area2D/AnimatedSprite2D.flip_h = true
		else:
			$Area2D/AnimatedSprite2D.animation = "side"
			$Area2D/AnimatedSprite2D.play()
			$Area2D/AnimatedSprite2D.flip_h = false
		
		if (true_y / x) > 3.5:
			$Area2D/AnimatedSprite2D.animation = "back"
			$Area2D/AnimatedSprite2D.play()
			$Area2D/AnimatedSprite2D.flip_h = false
		if (true_y / x) < -3.5:
			$Area2D/AnimatedSprite2D.animation = "front"
			$Area2D/AnimatedSprite2D.play()
			$Area2D/AnimatedSprite2D.flip_h = false
		
		if (x**2 + y**2)**0.5 < 10:
			delta_x = 0
			delta_y = 0
			$Area2D/AnimatedSprite2D.animation = "idle"
			$Area2D/AnimatedSprite2D.play()
			$Area2D/AnimatedSprite2D.flip_h = false
		
		if not above:
			delta_y *= -1
		if delta_x != 0 and delta_y != 0:
			attention.emit(position)
			
		pellet_param = [current_theta, delta_x, delta_y]
		
		position.x += delta_x
		position.y += delta_y
		
	

func blast():
	var pellet = PELLET.instantiate()
	pellet.Pellet(position, pellet_param)
	get_tree().current_scene.add_child(pellet)
	print(get_parent().get_tree_string_pretty())

	
func _input(event: InputEvent) -> void:
	if event.is_action_released("left_click") and $Area2D/AnimatedSprite2D.animation != "idle":
		blast()
	
func hurt():
	health -= 1
	
	
