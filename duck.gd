extends CharacterBody2D

var health = 3

const SPEED = 45000

var pellet_param = []
signal attention(pos)

@onready var sprite = $AnimatedSprite2D
@onready var PELLET = preload("res://pellet.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var mouse_pos = get_global_mouse_position()

	var left = position.x < mouse_pos.x
	
	var true_x = position.x - mouse_pos.x
	var true_y = position.y - mouse_pos.y
	var x = abs(true_x)
	var y = abs(true_y)
	
	var current_theta = atan(y/x)

	velocity.x = cos(current_theta) * SPEED * delta * -true_x / x
	velocity.y = sin(current_theta) * SPEED * delta * -true_y / y
	

	# animation if statements
	if (true_y / x) > 3.5:
		sprite.animation = "back"
		sprite.play()
		sprite.flip_h = false
	elif (true_y / x) < -3.5:
		sprite.animation = "front"
		sprite.play()
		sprite.flip_h = false
	elif not left:
		sprite.animation = "side"
		sprite.play()
		sprite.flip_h = true
	else:
		sprite.animation = "side"
		sprite.play()
		sprite.flip_h = false
	# deadzone implementation
	if (x**2 + y**2)**0.5 < 50:
		sprite.animation = "idle"
		sprite.play()
		velocity.x = 0
		velocity.y = 0

	pellet_param = [current_theta, velocity.x / 100, velocity.y / 100]
	if velocity.x != 0 or velocity.y != 0:
		attention.emit()

func _physics_process(delta: float) -> void:
	move_and_slide()

func blast():
	var pellet = PELLET.instantiate()
	pellet.Pellet(position, pellet_param)
	get_tree().current_scene.add_child(pellet)
	attention.emit()

func _input(event: InputEvent) -> void:
	if (event.is_action_released("left_click") or event.is_action_pressed("space")) and sprite.animation != "idle":
		blast()

func hurt():
	if health > 0:
		health -= 1
		
