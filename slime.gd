extends "enemy.gd"

@onready var sprite = $AnimatedSprite2D
@onready var PELLET = preload("res://pellet.tscn")

# Called when the node enters the scene tree for the first time.
func sprite_change(sprite, left, above, true_y, x):
	# idle
	if abs(x) < 10 or abs(true_y) < 10:
		
		sprite.play()
	elif (true_y / x) > 3.5:
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
	SPEED = randi_range(100, 250)
	health = 3
	cd = randf_range(1.0,3.0)
	base_modulate = Color(randf(), randf(), randf())
	$Sprite2D.modulate = base_modulate
# Called every frame. 'delta' is the elapsed time since the previous frame.

func _physics_process(delta: float) -> void:
	var dv_xy = movement(delta)
	velocity.x = dv_xy[0]
	velocity.y = dv_xy[1]
	move_and_slide()
	
func on_attention():
	var curr_time = Time.get_unix_time_from_system()
	if curr_time - last_time > cd or position == target_pos:
		last_time = curr_time
		
		var next_pos = get_tree().current_scene.find_child("Duck").position
		next_pos.x += randi_range(-250, 250)
		next_pos.y += randi_range(-250, 250)
		if next_pos == target_pos:
			wait = true
		else:
			wait = false 
			target_pos = next_pos

func _on_area_2d_area_entered(area: Area2D) -> void:
	print("SLIME OWWIE")
	area.get_parent().hurt()
