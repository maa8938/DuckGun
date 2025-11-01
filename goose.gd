extends "enemy.gd"

# Called when the node enters the scene tree for the first time.

func init():
	target_pos = Vector2(500, 500)
	position = Vector2(100, 100)
	SPEED = 300
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var delta_xy = movement(delta)
	position.x += delta_xy[0]
	position.y += delta_xy[1]
	
func on_attention():
	var curr_time = Time.get_unix_time_from_system()
	if curr_time - last_time > 1:
		#print(target_pos)
		last_time = curr_time
		target_pos = get_tree().current_scene.find_child("Duck").position
