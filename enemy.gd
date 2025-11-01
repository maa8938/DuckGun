extends Node2D

var target_pos # where the enemy is attempting to go
var change_target_time # the time between changing target pos
var SPEED # the enemy's speed
var damage # the number of hearts that are removed
var radius # kill zone for the dude

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func attack_duck():
	get_tree().current_scene.find_child("Duck").hurt()

func movement(delta):
	var left = position.x < target_pos.x
	var above = position.y < target_pos.y
	
	var true_x = position.x - target_pos.x
	var true_y = position.y - target_pos.y

	var x = abs(true_x)
	var y = abs(true_y)
	
	var current_theta = atan(y/x)
	
	var delta_x = cos(current_theta) * SPEED * delta
	var delta_y = sin(current_theta) * SPEED * delta
	
	return [delta_x, delta_y]
