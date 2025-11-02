extends "enemy.gd"

# Called when the node enters the scene tree for the first time.

func sprite_change(sprite, left, above, true_y, x):
	if wait:
		sprite.stop()
	else:
		if (true_y / x) > 3.5:
			sprite.play()
			sprite.rotation = deg_to_rad(180)
		elif (true_y / x) < -3.5:
			sprite.play()
			sprite.rotation = deg_to_rad(0)
		elif not left:
			sprite.play()
			sprite.rotation = deg_to_rad(90)
		else:
			sprite.play()
			sprite.rotation = deg_to_rad(270)
	

func set_sprite():
	spr = $Sprite2D

func init():
	target_pos = Vector2(500, 500)
	SPEED = 15000
	health = 3
	cd = randf_range(1.0,3.0)
# Called every frame. 'delta' is the elapsed time since the previous frame.

func _physics_process(delta: float) -> void:
	var dv_xy = movement(delta)
	velocity.x = dv_xy[0]
	velocity.y = dv_xy[1]
	move_and_slide()
	
func on_attention():
	var curr_time = Time.get_unix_time_from_system()
	if curr_time - last_time > cd:
		last_time = curr_time
		
		var next_pos = get_tree().current_scene.find_child("Duck").position
		if next_pos == target_pos:
			wait = true
		else:
			wait = false 
			target_pos = next_pos


	


func _on_area_2d_area_entered(area: Area2D) -> void:
	area.get_parent().hurt()
