extends "enemy.gd"

# Called when the node enters the scene tree for the first time.

func init():
	target_pos = Vector2(500, 500)
	SPEED = 15000
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#var delta_xy = movement(delta)
	pass
	
func _physics_process(delta: float) -> void:
	var dv_xy = movement(delta)
	velocity.x = dv_xy[0]
	velocity.y = dv_xy[1]
	move_and_slide()
	
func on_attention():
	var curr_time = Time.get_unix_time_from_system()
	if curr_time - last_time > 0.5:
		last_time = curr_time
		target_pos = get_tree().current_scene.find_child("Duck").position
		print(target_pos)
