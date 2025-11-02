extends Container

# Your tile *count* per unit
const LOGICAL_SCALE = 15
const ROOM_LOGICAL_WIDTH = 3
# Your pixel *size* per tile
const TILE_PIXELS = 16

# Calculated widths in *tiles*
const PATH_TILES = LOGICAL_SCALE # 1 * 15 = 15
const ROOM_TILES = ROOM_LOGICAL_WIDTH * LOGICAL_SCALE # 3 * 15 = 45

# Calculated widths in *pixels*
const PATH_PIXELS = PATH_TILES * TILE_PIXELS # 15 * 16 = 240
const ROOM_PIXELS = ROOM_TILES * TILE_PIXELS # 45 * 16 = 720

var grid_size = 50 * LOGICAL_SCALE # 750
var rooms = 15
@onready var tilemap = $HedgeMazeMap
@onready var tileSet = tilemap.tile_set

var grid = []
var room_indexes = {
	1: [14, 8, 13, 12], 2: [7, 7, 9, 9], 3: [10, 17, 16, 15], 4: [11, 11, 11, 11]
}
var path_indexes = {
	0: [20, 6, 19, 21], 1: [2, 2, 18, 18], 3: [27, 25, 4, 26], 4: [3, 3, 3, 3]
}

const MIN_PATH_LENGTH = 3
const MAX_PATH_LENGTH = 8
const ROOM_CHANCE = 0.3

func _ready() -> void:
	for i in range(grid_size):
		grid.append([])
		for j in range(grid_size):
			grid[-1].append(0)
			
	var X = LOGICAL_SCALE
	var Y = LOGICAL_SCALE
	
	create_room(X, Y, 0)

# --- NEW FUNCTIONS FOR VISIBILITY ---

func _on_area_entered(body, light: PointLight2D):
	if body.is_in_group("player"):
		light.enabled = true

func _on_area_exited(body, light: PointLight2D):
	if body.is_in_group("player"):
		light.enabled = false

# This function adds the light and trigger area
func add_visibility_area(tile_pos_x: int, tile_pos_y: int, size_in_pixels: Vector2):
	# Calculate pixel position
	var pixel_pos = tilemap.map_to_local(Vector2i(tile_pos_x, tile_pos_y))
	var centered_pos = pixel_pos + size_in_pixels / 2.0
	
	# Create the light
	var light = PointLight2D.new()
	var tex = PlaceholderTexture2D.new() # A simple white square
	tex.size = size_in_pixels
	light.texture = tex
	light.enabled = false # Off by default
	light.position = centered_pos
	
	# Create the trigger area
	var area = Area2D.new()
	var rect = RectangleShape2D.new()
	rect.size = size_in_pixels
	var shape = CollisionShape2D.new()
	shape.shape = rect
	area.add_child(shape)
	area.position = centered_pos
	
	# Connect signals
	# We "bind" the 'light' variable to the signal
	area.body_entered.connect(_on_area_entered.bind(light))
	area.body_exited.connect(_on_area_exited.bind(light))
	
	# Add to the scene tree (as children of this Container node)
	add_child(area)
	add_child(light)

# --- END NEW FUNCTIONS ---


## This is the "path carving" function
func create_path(X, Y, came_from_dir, current_length = 0):
	if not can_place_path(X, Y):
		return

	var try_place_room = false
	
	if rooms > 0:
		if current_length > MIN_PATH_LENGTH and randf() < ROOM_CHANCE:
			try_place_room = true
		if current_length > MAX_PATH_LENGTH:
			try_place_room = true
	else:
		mark_path_grid(X, Y)
		var dead_end_index = path_indexes[0][came_from_dir]
		place_tile(X, Y, dead_end_index)
		# Add visibility for the dead end
		add_visibility_area(X, Y, Vector2(PATH_PIXELS, PATH_PIXELS))
		return
		
	if try_place_room:
		var room_pos = get_room_pos_from_path(X, Y, came_from_dir)
		var room_X = room_pos[0]
		var room_Y = room_pos[1]
		
		if create_room(room_X, room_Y, came_from_dir):
			mark_path_grid(X, Y)
			var dead_end_index = path_indexes[0][came_from_dir]
			place_tile(X, Y, dead_end_index)
			# Add visibility for the connecting dead end
			add_visibility_area(X, Y, Vector2(PATH_PIXELS, PATH_PIXELS))
			return 
		else:
			mark_path_grid(X, Y)
			var dead_end_index = path_indexes[0][came_from_dir]
			place_tile(X, Y, dead_end_index)
			# Add visibility for the failed dead end
			add_visibility_area(X, Y, Vector2(PATH_PIXELS, PATH_PIXELS))
			return 
			
	mark_path_grid(X, Y)
	
	var path_type_roll = randi_range(1, 10)
	var rand_path_type
	if path_type_roll <= 6: rand_path_type = 1
	elif path_type_roll <= 8: rand_path_type = 3
	else: rand_path_type = 4
		
	var path_pattern_index = path_indexes[rand_path_type][came_from_dir]
	place_tile(X, Y, path_pattern_index)
	
	# Add visibility for the path
	add_visibility_area(X, Y, Vector2(PATH_PIXELS, PATH_PIXELS))

	var exits = get_path_exits(X, Y, rand_path_type, came_from_dir)
	for exit in exits:
		create_path(exit[0], exit[1], exit[2], current_length + 1)


## This is the "room placing" function
func create_room(X, Y, came_from_dir) -> bool:
	if not can_place_room(X, Y):
		return false 

	rooms -= 1
	for y in range(ROOM_TILES):
		for x in range(ROOM_TILES):
			grid[Y+y][X+x] = 1
			
	var rand_enterances = randi_range(1, 4)
	var roomIndex = room_indexes[rand_enterances][came_from_dir]
	var normalRoom = tileSet.get_pattern(roomIndex)
	
	if normalRoom:
		tilemap.set_pattern(Vector2i(X, Y), normalRoom)
	else:
		push_error("Room pattern not found: " + str(roomIndex))

	# Add visibility for the room
	add_visibility_area(X, Y, Vector2(ROOM_PIXELS, ROOM_PIXELS))

	if rooms <= 0:
		return true 

	var directions = [0, 1, 2, 3]
	directions.shuffle()
	
	for dir in directions:
		if dir == came_from_dir:
			continue
			
		var path_data = get_path_pos_from_room(X, Y, dir)
		var path_X = path_data[0]
		var path_Y = path_data[1]
		var next_came_from_dir = path_data[2]
		
		create_path(path_X, path_Y, next_came_from_dir, 0)

	return true 


# ===================================================================
# ======================== HELPER FUNCTIONS =========================
# ===================================================================

func place_tile(X, Y, pattern_index):
	var pattern = tileSet.get_pattern(pattern_index)
	if pattern:
		tilemap.set_pattern(Vector2i(X, Y), pattern)
	else:
		push_error("Path pattern not found: " + str(pattern_index))

func mark_path_grid(X, Y):
	for y in range(PATH_TILES):
		for x in range(PATH_TILES):
			if X+x >= 0 and X+x < grid_size and Y+y >= 0 and Y+y < grid_size:
				grid[Y+y][X+x] = 1

func can_place_path(X, Y) -> bool:
	for y in range(PATH_TILES):
		for x in range(PATH_TILES):
			var check_X = X + x
			var check_Y = Y + y
			if check_X < 0 or check_X >= grid_size or check_Y < 0 or check_Y >= grid_size:
				return false
			if grid[check_Y][check_X] == 1:
				return false
	return true

func can_place_room(X, Y) -> bool:
	if rooms <= 0:
		return false
	for y in range(ROOM_TILES):
		for x in range(ROOM_TILES):
			var check_X = X + x
			var check_Y = Y + y
			if check_X < 0 or check_X >= grid_size or check_Y < 0 or check_Y >= grid_size:
				return false
			if grid[check_Y][check_X] == 1:
				return false
	return true

func get_path_pos_from_room(X, Y, exit_dir) -> Array:
	var door_offset = int((ROOM_TILES - PATH_TILES) / 2.0) # (45 - 15) / 2 = 15
	
	if exit_dir == 0: return [X + door_offset, Y - PATH_TILES, 1] 
	elif exit_dir == 1: return [X + door_offset, Y + ROOM_TILES, 0] 
	elif exit_dir == 2: return [X + ROOM_TILES, Y + door_offset, 3] 
	else: return [X - PATH_TILES, Y + door_offset, 2] 

func get_room_pos_from_path(X, Y, came_from_dir) -> Array:
	var door_offset = int((ROOM_TILES - PATH_TILES) / 2.0) # 15
	
	if came_from_dir == 0: return [X - door_offset, Y + PATH_TILES] 
	elif came_from_dir == 1: return [X - door_offset, Y - ROOM_TILES] 
	elif came_from_dir == 2: return [X - ROOM_TILES, Y - door_offset] 
	else: return [X + PATH_TILES, Y - door_offset] 

func get_path_exits(X, Y, path_type, came_from_dir) -> Array:
	var exits = []
	
	var north_exit = [X, Y - PATH_TILES, 1]
	var south_exit = [X, Y + PATH_TILES, 0]
	var east_exit =  [X + PATH_TILES, Y, 3]
	var west_exit =  [X - PATH_TILES, Y, 2]
	
	var all_dirs = [north_exit, south_exit, east_exit, west_exit]
	
	if path_type == 1:
		if came_from_dir == 0: exits.append(south_exit)
		if came_from_dir == 1: exits.append(north_exit)
		if came_from_dir == 2: exits.append(west_exit)
		if came_from_dir == 3: exits.append(east_exit)
	elif path_type == 3:
		if came_from_dir == 0:
			exits.append(east_exit)
			exits.append(west_exit)
		if came_from_dir == 1:
			exits.append(east_exit)
			exits.append(west_exit)
		if came_from_dir == 2:
			exits.append(north_exit)
			exits.append(south_exit)
		if came_from_dir == 3:
			exits.append(north_exit)
			exits.append(south_exit)
	elif path_type == 4:
		for i in range(4):
			if i != came_from_dir: 
				exits.append(all_dirs[i])
				
	return exits
