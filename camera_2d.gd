extends Camera2D

@onready var player = $"../Duck"

@export var smoothing: float = 3

func _ready() -> void:
	set_as_top_level(true)

func _process(delta: float) -> void:
	var player_gpos = player.global_position
	var mouse_gpos = get_global_mouse_position()
	
	if abs(mouse_gpos.x) > get_viewport().size.x * 0.6:
		mouse_gpos.x = (get_viewport().size.x * abs(mouse_gpos.x) / mouse_gpos.x) * .6
	if abs(mouse_gpos.y) > get_viewport().size.y * 0.5:
		mouse_gpos.y = (get_viewport().size.y * abs(mouse_gpos.y) / mouse_gpos.y) * .5
	
	
	var target_pos = (player_gpos + mouse_gpos) / 2.0
	var distance = ((position.x - target_pos.x) ** 2 + (position.y - target_pos.x) ** 2) ** 0.5
	if player.sprite.animation != "idle":
		global_position = global_position.lerp(target_pos, smoothing * delta)
