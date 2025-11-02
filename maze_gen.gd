extends Container

# The size of our smallest logical "unit" in tiles.
# A path is 1x1 units (15x15 tiles).
const LOGICAL_UNIT_SIZE = 15
# A room is 3x3 logical units (45x45 tiles).
const ROOM_LOGICAL_WIDTH = 3
# Your pixel *size* per tile
const TILE_PIXELS = 16

# Calculated widths in *tiles*
const PATH_TILES = LOGICAL_UNIT_SIZE # 15
const ROOM_TILES = ROOM_LOGICAL_WIDTH * LOGICAL_UNIT_SIZE # 45

# Calculated widths in *pixels*
const PATH_PIXELS = PATH_TILES * TILE_PIXELS # 15 * 16 = 240
const ROOM_PIXELS = ROOM_TILES * TILE_PIXELS # 45 * 16 = 720

var rooms = 15
@onready var tilemap = $HedgeMazeMap
@onready var tileSet = tilemap.tile_set

# This grid stores what *type* of thing is at a logical spot
# 0 = Empty, 1 = Path, 2 = Room
var logical_grid = []
var logical_grid_size = 50 # 50 logical units wide

var room_indexes = {
	1: [14, 8, 13, 12], 2: [7, 7, 9, 9], 3: [10, 17, 16, 15], 4: [11, 11, 11, 11]
}
var path_indexes = {
	0: [20, 6, 19, 21], 1: [2, 2, 18, 18], 3: [27, 25, 4, 26], 4: [3, 3, 3, 3]
}

# --- Generation Tuners ---
const MIN_PATH_LENGTH = 3
const MAX_PATH_LENGTH = 8
const ROOM_CHANCE = 0.3
const LOOP_CHANCE = 0.4 # 40% chance for a dead-end to create a loop

# This list will store the *logical* (X,Y) coords of all placed dead-ends
var dead_ends_list = []

func _ready() -> void:
	# 1. Initialize the *logical* 50x50 grid
	for i in range(logical_grid_size):
		logical_grid.append([])
		for j in range(logical_grid_size):
			logical_grid[-1].append(0)
			
	# 2. Start the generation
	# We start at logical coord (5, 5)
	var start_X = 5
	var start_Y = 5
	
	# Place the *first* room.
	# We pretend we entered from the North (0).
	# We give it 2-4 connections to kick-start the recursion.
	create_room(start_X, start_Y, 0, randi_range(2, 4))
	
	# 3. --- CREATE INTERLINKING LOOPS ---
	# After the whole maze is built, call the loop-creator
	create_loops()


# --- VISIBILITY FUNCTIONS ---

func _on_area_entered(body, light: PointLight2D):
	if body.is_in_group("player"):
		light.enabled = true

func _on_area_exited(body, light: PointLight2D):
	if body.is_in_group("player"):
		light.enabled = false

func add_visibility_area(logical_X: int, logical_Y: int, is_room: bool):
	# This function now correctly places lights based on the
	# logical grid units, not the tile grid.
	var pixel_size = Vector2(PATH_PIXELS, PATH_PIXELS)
	var tile_pos = Vector2i(logical_X * LOGICAL_UNIT_SIZE, logical_Y * LOGICAL_UNIT_SIZE)
	
	if is_room:
		pixel_size = Vector2(ROOM_PIXELS, ROOM_PIXELS)
	
	var pixel_pos_world = tilemap.map_to_local(tile_pos)
	var centered_pos = pixel_pos_world + pixel_size / 2.0
	
	var light = PointLight2D.new()
	var tex = PlaceholderTexture2D.new()
	tex.size = pixel_size
	light.texture = tex
	light.enabled = false # Start with lights OFF
	light.position = centered_pos
	
	var area = Area2D.new()
	var rect = RectangleShape2D.new()
	rect.size = pixel_size
	var shape = CollisionShape2D.new()
	shape.shape = rect
	area.add_child(shape)
	area.position = centered_pos
	
	area.body_entered.connect(_on_area_entered.bind(light))
	area.body_exited.connect(_on_area_exited.bind(light))
	
	add_child(area)
	add_child(light)

# --- GENERATION FUNCTIONS ---

## This is the "path carving" function
func create_path(logical_X: int, logical_Y: int, came_from_dir: int, current_length: int = 0):
	# Base Case 1: Is this 1x1 logical spot valid?
	if not can_place_path(logical_X, logical_Y):
		return

	var try_place_room = false
	
	# Base Case 2: Are we out of rooms?
	if rooms <= 0:
		place_dead_end(logical_X, logical_Y, came_from_dir)
		return
	
	# Decide if we should try to place a room
	if current_length > MIN_PATH_LENGTH and randf() < ROOM_CHANCE:
		try_place_room = true
	if current_length > MAX_PATH_LENGTH:
		try_place_room = true
		
	# Base Case 3: Try to place a room
	if try_place_room:
		var room_pos = get_room_pos_from_path(logical_X, logical_Y, came_from_dir)
		
		# Decide how many connections this *new* room will have
		var new_room_connections = randi_range(1, 4)
		
		if create_room(room_pos[0], room_pos[1], came_from_dir, new_room_connections):
			# --- SUCCESS ---
			# Place the final "dead end" path tile that connects to the new room
			place_dead_end(logical_X, logical_Y, came_from_dir)
			return # Stop this path
		else:
			# --- FAILURE (blocked) ---
			# Place a dead end and stop this path
			place_dead_end(logical_X, logical_Y, came_from_dir)
			return
			
	# --- Recursive Step: Carve a path ---
	logical_grid[logical_Y][logical_X] = 1 # Mark 1x1 logical grid as path
	
	var path_type_roll = randi_range(1, 10)
	var rand_path_type
	if path_type_roll <= 6: rand_path_type = 1 # 60% Straight
	elif path_type_roll <= 8: rand_path_type = 3 # 20% T-Shape
	else: rand_path_type = 4 # 20% 4-Way
		
	var path_pattern_index = path_indexes[rand_path_type][came_from_dir]
	place_tile(logical_X, logical_Y, path_pattern_index, false) # false = not a room
	
	# Get *all* new exits from the path we just placed
	var exits = get_path_exits(logical_X, logical_Y, rand_path_type, came_from_dir)
	for exit in exits:
		# Recurse for each new exit
		create_path(exit[0], exit[1], exit[2], current_length + 1)


## This is the logical "room placing" function
func create_room(logical_X: int, logical_Y: int, came_from_dir: int, total_connections: int) -> bool:
	# 1. Validation: Can we place a 3x3 room here?
	if not can_place_room(logical_X, logical_Y):
		return false # Failed to place

	# 2. Mark Grid & Decrement Rooms
	rooms -= 1
	# Mark all 3x3 logical cells as "Room"
	for y in range(ROOM_LOGICAL_WIDTH):
		for x in range(ROOM_LOGICAL_WIDTH):
			# --- MINOR BUG FIX: Check bounds *before* writing to grid ---
			var check_X = logical_X + x
			var check_Y = logical_Y + y
			if is_in_bounds(check_X, check_Y):
				logical_grid[check_Y][check_X] = 2 # 2 = Room
			
	# 3. Get the correct pattern based on connection count
	var roomIndex = room_indexes[total_connections][came_from_dir]
	place_tile(logical_X, logical_Y, roomIndex, true) # true = is a room

	# 4. Stop if we're out of rooms
	if rooms <= 0:
		return true 

	# 5. Calculate how many *new* paths we must create
	var new_paths_needed = total_connections - 1
	if new_paths_needed <= 0:
		return true # This was a 1-connection (dead-end) room. We are done.

	# 6. Find all *possible* new path directions
	var possible_directions = []
	var directions = [0, 1, 2, 3] # N, S, E, W
	directions.shuffle()
	
	for dir in directions:
		if dir == came_from_dir:
			continue
			
		# Get path data (logical_X, logical_Y, next_came_from_dir)
		var path_data = get_path_pos_from_room(logical_X, logical_Y, dir)
		# Check if the 1x1 path spot is valid
		if can_place_path(path_data[0], path_data[1]):
			possible_directions.append(path_data)
	
	# 7. Create new paths, up to the max we need
	var paths_created = 0
	for path_data in possible_directions:
		if paths_created >= new_paths_needed:
			break 
		
		create_path(path_data[0], path_data[1], path_data[2], 0)
		paths_created += 1

	return true 

## --- NEW FUNCTION TO CREATE LOOPS ---
func create_loops():
	# This function runs *after* the maze is built
	# It iterates over all the dead ends and *sometimes*
	# connects them to a neighbor to create a loop.
	
	for dead_end_data in dead_ends_list:
		var logical_X = dead_end_data[0]
		var logical_Y = dead_end_data[1]
		var came_from_dir = dead_end_data[2]
		
		if randf() > LOOP_CHANCE:
			continue # Skip this dead end
			
		# Find a valid neighbor to connect to
		var directions = [0, 1, 2, 3]
		directions.shuffle()
		
		for dir in directions:
			if dir == came_from_dir:
				continue # Don't connect back the way we came
			
			var neighbor_X = logical_X
			var neighbor_Y = logical_Y
			var neighbor_came_from_dir = -1
			
			if dir == 0: # Check North
				neighbor_Y -= 1
				neighbor_came_from_dir = 1 # Neighbor would be entered from South
			if dir == 1: # Check South
				neighbor_Y += 1
				neighbor_came_from_dir = 0 # Neighbor would be entered from North
			if dir == 2: # Check East
				neighbor_X += 1
				neighbor_came_from_dir = 3 # Neighbor would be entered from West
			if dir == 3: # Check West
				neighbor_X -= 1
				neighbor_came_from_dir = 2 # Neighbor would be entered from East
			
			# Check if neighbor is valid and *not* empty
			if is_in_bounds(neighbor_X, neighbor_Y) and logical_grid[neighbor_Y][neighbor_X] != 0:
				# --- FOUND A LOOP ---
				# We replace the dead-end tile with a T-shape
				# to connect to the neighbor.
				
				# Get the T-shape pattern for the *original* entry direction
				var new_path_index = path_indexes[3][came_from_dir]
				
				place_tile(logical_X, logical_Y, new_path_index, false)
				
				# We only create one loop per dead end, so break
				break

# ===================================================================
# ======================== HELPER FUNCTIONS =========================
# ===================================================================

func place_tile(logical_X: int, logical_Y: int, pattern_index: int, is_room: bool):
	# Convert logical coords to tile coords
	var tile_X = logical_X * LOGICAL_UNIT_SIZE
	var tile_Y = logical_Y * LOGICAL_UNIT_SIZE
	
	var pattern = tileSet.get_pattern(pattern_index)
	if pattern:
		tilemap.set_pattern(Vector2i(tile_X, tile_Y), pattern)
		add_visibility_area(logical_X, logical_Y, is_room)
	else:
		push_error("Pattern not found: " + str(pattern_index))

func place_dead_end(logical_X: int, logical_Y: int, came_from_dir: int):
	logical_grid[logical_Y][logical_X] = 1 # Mark as path
	var dead_end_index = path_indexes[0][came_from_dir]
	place_tile(logical_X, logical_Y, dead_end_index, false)
	# Add this to our list for the loop-making function
	dead_ends_list.append([logical_X, logical_Y, came_from_dir])

func is_in_bounds(logical_X: int, logical_Y: int) -> bool:
	if logical_X < 0 or logical_X >= logical_grid_size or logical_Y < 0 or logical_Y >= logical_grid_size:
		return false
	return true

## Checks if a 1x1 logical path can be placed
func can_place_path(logical_X: int, logical_Y: int) -> bool:
	if not is_in_bounds(logical_X, logical_Y):
		return false
	if logical_grid[logical_Y][logical_X] != 0: # 0 = Empty
		return false
	return true

## Checks if a 3x3 logical room can be placed
func can_place_room(logical_X: int, logical_Y: int) -> bool:
	if rooms <= 0:
		return false
	# Check 3x3 logical area
	for y in range(ROOM_LOGICAL_WIDTH):
		for x in range(ROOM_LOGICAL_WIDTH):
			var check_X = logical_X + x
			var check_Y = logical_Y + y
			if not is_in_bounds(check_X, check_Y):
				return false # Out of bounds
			if logical_grid[check_Y][check_X] != 0: # 0 = Empty
				return false # Occupied
	return true

## Gets the 1x1 logical path pos *from* a 3x3 logical room pos
func get_path_pos_from_room(room_X: int, room_Y: int, exit_dir: int) -> Array:
	# Center of the 3x3 room (logical 0, 1, 2) is at offset 1
	var door_offset = int(ROOM_LOGICAL_WIDTH / 2.0) # 3/2 = 1
	
	if exit_dir == 0: # Exit NORTH
		return [room_X + door_offset, room_Y - 1, 1] # Path is North, enters from South
	if exit_dir == 1: # Exit SOUTH
		return [room_X + door_offset, room_Y + ROOM_LOGICAL_WIDTH, 0] # Path is South, enters from North
	if exit_dir == 2: # Exit EAST
		return [room_X + ROOM_LOGICAL_WIDTH, room_Y + door_offset, 3] # Path is East, enters from West
	else: # Exit WEST (3)
		return [room_X - 1, room_Y + door_offset, 2] # Path is West, enters from East

## Gets the 3x3 logical room pos *from* a 1x1 logical path pos
func get_room_pos_from_path(path_X: int, path_Y: int, came_from_dir: int) -> Array:
	var door_offset = int(ROOM_LOGICAL_WIDTH / 2.0) # 1
	
	if came_from_dir == 0: # Path came from NORTH
		return [path_X - door_offset, path_Y + 1] # Room is South
	if came_from_dir == 1: # Path came from SOUTH
		return [path_X - door_offset, path_Y - ROOM_LOGICAL_WIDTH] # Room is North
	if came_from_dir == 2: # Path came from EAST
		return [path_X - ROOM_LOGICAL_WIDTH, path_Y - door_offset] # Room is West
	else: # Path came from WEST (3)
		return [path_X + 1, path_Y - door_offset] # Room is East

## Gets the 1x1 logical exits *from* a 1x1 logical path
func get_path_exits(logical_X: int, logical_Y: int, path_type: int, came_from_dir: int) -> Array:
	var exits = []
	
	var north_exit = [logical_X, logical_Y - 1, 1]
	var south_exit = [logical_X, logical_Y + 1, 0]
	var east_exit =  [logical_X + 1, logical_Y, 3]
	var west_exit =  [logical_X - 1, logical_Y, 2]
	
	var all_dirs = [north_exit, south_exit, east_exit, west_exit]
	
	if path_type == 1: # Straight
		if came_from_dir == 0: exits.append(south_exit) 
		if came_from_dir == 1: exits.append(north_exit)
		if came_from_dir == 2: exits.append(west_exit)
		if came_from_dir == 3: exits.append(east_exit)
	elif path_type == 3: # T-Shape
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
	elif path_type == 4: # 4-Way
		for i in range(4):
			if i != came_from_dir: 
				exits.append(all_dirs[i])
				
	return exits
