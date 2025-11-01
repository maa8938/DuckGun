# 1. Change this to CharacterBody2D
extends CharacterBody2D

# --- No longer needed ---
# var bounce = false
# var og_d_x = 0
# var og_d_y = 0
# -----------------------

const SPEED = 350
var pellet_param = []
@onready var PELLET = preload("res://pellet.tscn")

# You can cache this for convenience
@onready var animated_sprite = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# 2. Use _physics_process for all movement and physics
func _physics_process(delta: float) -> void:
	# Use global_mouse_position for coordinates in the game world
	var mouse_pos = get_global_mouse_position()

	# 3. Calculate direction and distance
	var direction = (mouse_pos - global_position).normalized()
	var distance = global_position.distance_to(mouse_pos)
	
	var deadzone = 10
	
	# 4. Set velocity based on direction and deadzone
	if distance > deadzone:
		velocity = direction * SPEED
	else:
		velocity = Vector2.ZERO

	# 5. Let Godot handle collisions!
	# This single line moves the player, collides with physics bodies
	# (like StaticBody2D walls), and slides along them smoothly.
	move_and_slide()

	# 6. Update animations based on the final velocity
	update_animations()
	
	# 7. Store parameters for the pellet
	# We store the angle (in radians) and the velocity vector
	pellet_param = [direction.angle(), velocity.x, velocity.y]


func update_animations():
	if velocity.length_squared() < 0.1:
		# Not moving
		animated_sprite.animation = "idle"
		animated_sprite.play()
		animated_sprite.flip_h = false
		return # Exit the function early

	# If we're here, we are moving.
	animated_sprite.play()
	
	# Check for division by zero (moving purely vertically)
	if velocity.x == 0:
		if velocity.y < 0:
			animated_sprite.animation = "back"
			animated_sprite.flip_h = false
		else:
			animated_sprite.animation = "front"
			animated_sprite.flip_h = false
	else:
		# Moving with some horizontal component, so division is safe
		var ratio = abs(velocity.y / velocity.x)
		
		if ratio > 3.5:
			# Prioritize vertical animation
			if velocity.y < 0:
				animated_sprite.animation = "back"
				animated_sprite.flip_h = false
			else:
				animated_sprite.animation = "front"
				animated_sprite.flip_h = false
		else:
			# Prioritize horizontal animation
			animated_sprite.animation = "side"
			if velocity.x < 0:
				animated_sprite.flip_h = true # Moving left
			else:
				animated_sprite.flip_h = false # Moving right


func blast():
	var pellet = PELLET.instantiate()
	# Pass global_position so it spawns in the right world-space location
	pellet.Pellet(global_position, pellet_param)
	get_tree().current_scene.add_child(pellet)
	# print(get_parent().get_tree_string_pretty())


# 8. --- REMOVE THESE FUNCTIONS ---
# They are no longer needed, as move_and_slide() handles wall collisions.
#
# func _on_body_entered(body: Node2D) -> void:
# 	if body.is_in_group("Walls"):
# 		bounce = true
#
# func _on_body_exited(body: Node2D) -> void:
# 	if body.is_in_group("Walls"):
# 		bounce = false
# ---------------------------------


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("shoot") and animated_sprite.animation != "idle":
		blast()
