extends "enemy.gd"

# Called when the node enters the scene tree for the first time.

func sprite_change(sprite, left, above, true_y, x):
	if not left:
		sprite.play()
		sprite.rotation = deg_to_rad(90)
	else:
		sprite.play()
		sprite.rotation = deg_to_rad(270)

	if (true_y / x) > 3.5:
		sprite.play()
		sprite.rotation = deg_to_rad(180)
	if (true_y / x) < -3.5:
		sprite.play()
		sprite.rotation = deg_to_rad(0)
	

func set_sprite():
	spr = $Sprite2D

func init():
	target_pos = Vector2(500, 500)
	SPEED = 15000
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _physics_process(delta: float) -> void:
	var dv_xy = movement(delta)
	velocity.x = dv_xy[0]
	velocity.y = dv_xy[1]
	move_and_slide()
	
func on_attention():
	var curr_time = Time.get_unix_time_from_system()
	if curr_time - last_time > 1:
		last_time = curr_time
		target_pos = get_tree().current_scene.find_child("Duck").position


	
