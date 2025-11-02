extends CharacterBody2D

var target_pos # where the enemy is attempting to go
var change_target_time # the time between changing target pos
var SPEED # the enemy's speed
var damage # the number of hearts that are removed
var radius # kill zone for the dude
var last_time = 0
var cd 
var health 
var wait = false
const unchanged = null
var spr
var ouch_time = 0
var base_modulate = Color(1,1,1,1)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	init()
	var duck = get_tree().current_scene.get_node("Gameplay").get_node("Duck")
	duck.attention.connect(on_attention)
	

func init():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if ouch_time > 0:
		ouch_time -= delta
	else:
		spr.modulate = base_modulate
	#print(health, self)
	
	
func attack_duck():
	get_tree().current_scene.find_child("Duck").hurt()

func movement(delta):
	if position == target_pos:
		return [0,0]
	var left = position.x < target_pos.x
	var above = position.y < target_pos.y
	
	var true_x = position.x - target_pos.x
	var true_y = position.y - target_pos.y
	var x = abs(true_x)
	var y = abs(true_y)
	
	if x == 0:
		x = 0.01
	if y == 0:
		y = 0.01
	
	var h = sqrt((x**2) + (y**2))
	var a = x
	var o = y
	
	
	#var current_theta = atan(y/x)
	var deadzone = 10

	var vx = a/h * SPEED * -true_x / x
	var vy = o/h * SPEED * -true_y / y
	
	if spr != unchanged:
		sprite_change(spr, left, above, true_y, x)
	else:
		set_sprite()
	
	return [vx, vy]

func set_sprite():
	pass

func sprite_change(sprite, left, above, true_y, x):
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

func on_attention():
	pass
	
func hurt():
	if health > 1:
		health -= 1
		spr.modulate = Color.RED
		ouch_time = 0.1
	else: 
		queue_free()
