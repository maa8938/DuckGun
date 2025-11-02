extends Camera2D

@onready var player = $"../Duck"

@export var smoothing: float = 3

var duck_alive = true

func _ready() -> void:
	set_as_top_level(true)

func _process(delta: float) -> void:
	if duck_alive:
		var player_gpos = player.global_position
		var mouse_gpos = get_global_mouse_position()
		
		#var t_x = mouse_gpos.x / get_viewport().size.x - floor(mouse_gpos.x / get_viewport().size.x)
		#var t_y = mouse_gpos.y / get_viewport().size.y - floor(mouse_gpos.x / get_viewport().size.x)
		
		#if t_x >= 0.6:
			#mouse_gpos.x += (get_viewport().size.x * abs(mouse_gpos.x) / mouse_gpos.x)
		#if t_y >= 0.5:
			#mouse_gpos.y += (get_viewport().size.y * abs(mouse_gpos.y) / mouse_gpos.y)
		
		
		var target_pos = (player_gpos + mouse_gpos) / 2.0
		if player.sprite.animation != "idle":
			global_position = global_position.lerp(target_pos, smoothing * delta)


func _on_duck_died() -> void:
	duck_alive = false
	global_position = Vector2(0,0)
