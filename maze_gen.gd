extends Container

# --- THIS IS THE FIX ---
# A "logical 1x1" unit (like a path) is 15x15 tiles.
const LOGICAL_SCALE = 15
# A "logical 3x3" room is 3 "logical units" wide.
const ROOM_LOGICAL_WIDTH = 3
# ---------------------

# Calculated widths in *tiles*
const PATH_TILES = LOGICAL_SCALE # 1 * 15 = 15
const ROOM_TILES = ROOM_LOGICAL_WIDTH * LOGICAL_SCALE # 3 * 15 = 45

# We still use a 750x750 *tile* grid.
var grid_size = 50 * LOGICAL_SCALE # 750
var rooms = 15
@onready var tilemap = $HedgeMazeMap
@onready var tileSet = tilemap.tile_set

# This is the large 750x750 grid, where 1 cell = 1 tile
var grid = []
var room_indexes = {
	1: [14, 8, 13, 12], 
	2: [7, 7, 9, 9], 
	3: [10, 17, 16, 15], 
	4: [11, 11, 11, 11]
}
var path_indexes = {
	0: [20, 6, 19, 21], # Dead end
	1: [2, 2, 18, 18], # Straight
	# 2: Left turn (REMOVED)
	3: [27, 25, 4, 26], # T shape
	4: [3, 3, 3, 3]  # 4 way intersection
}

# --- Generation Tuners ---
const MIN_PATH_LENGTH = 3  # Min path "segments" before trying to place a room
const MAX_PATH_LENGTH = 8  # Max path "segments" before FORCING a room
const ROOM_CHANCE = 0.3    # 30% chance to place a room


func _ready() -> void:
	for i in range(grid_size):
		grid.append([])
		for j in range(grid_size):
			grid[-1].append(0)
			
	# Start tile coordinate (e.g., 15, 15)
	var X = LOGICAL_SCALE
	var Y = LOGICAL_SCALE
	
	create_room(X, Y, 0)


## This is the "path carving" function
## X, Y are the TOP-LEFT TILE of a 15x15 path segment
func create_path(X, Y, came_from_dir, current_length = 0):
	# Base Case 1: Is this 15x15 spot valid?
	if not can_place_path(X, Y):
		return

	var try_place_room = false
	
	if rooms > 0:
		if current_length > MIN_PATH_LENGTH and randf() < ROOM_CHANCE:
			try_place_room = true
		if current_length > MAX_PATH_LENGTH:
			try_place_room = true
	else:
		# Base Case 2: We are out of rooms
		mark_path_grid(X, Y)
		var dead_end_index = path_indexes[0][came_from_dir]
		place_tile(X, Y, dead_end_index)
		return
		

	# Base Case 3: Try to place a room
	if try_place_room:
		var room_pos = get_room_pos_from_path(X, Y, came_from_dir)
		var room_X = room_pos[0]
		var room_Y = room_pos[1]
		
		if create_room(room_X, room_Y, came_from_dir):
			# --- SUCCESS ---
			mark_path_grid(X, Y)
			var dead_end_index = path_indexes[0][came_from_dir]
			place_tile(X, Y, dead_end_index)
			return 
		else:
			# --- FAILURE (blocked) ---
			mark_path_grid(X, Y)
			var dead_end_index = path_indexes[0][came_from_dir]
			place_tile(X, Y, dead_end_index)
			return 
			
	# --- Recursive Step: Carve a path ---
	mark_path_grid(X, Y) # Mark 15x15 area
	
	var path_type_roll = randi_range(1, 10)
	var rand_path_type
	if path_type_roll <= 6: rand_path_type = 1
	elif path_type_roll <= 8: rand_path_type = 3
	else: rand_path_type = 4
		
	var path_pattern_index = path_indexes[rand_path_type][came_from_dir]
	place_tile(X, Y, path_pattern_index)

	var exits = get_path_exits(X, Y, rand_path_type, came_from_dir)
	for exit in exits:
		create_path(exit[0], exit[1], exit[2], current_length + 1)


## This is the "room placing" function
## X, Y are the TOP-LEFT TILE of a 45x45 room
func create_room(X, Y, came_from_dir) -> bool:
	if not can_place_room(X, Y):
		return false 

	rooms -= 1
	# Mark 45x45 area as occupied
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

## Places a single tile pattern (which is 15x15 or 45x45)
func place_tile(X, Y, pattern_index):
	var pattern = tileSet.get_pattern(pattern_index)
	if pattern:
		tilemap.set_pattern(Vector2i(X, Y), pattern)
	else:
		push_error("Path pattern not found: " + str(pattern_index))

## Marks a 15x15 path area as occupied
func mark_path_grid(X, Y):
	for y in range(PATH_TILES):
		for x in range(PATH_TILES):
			if X+x >= 0 and X+x < grid_size and Y+y >= 0 and Y+y < grid_size:
				grid[Y+y][X+x] = 1

## Checks if a 15x15 path tile can be placed
func can_place_path(X, Y) -> bool:
	# Check 15x15 area
	for y in range(PATH_TILES):
		for x in range(PATH_TILES):
			var check_X = X + x
			var check_Y = Y + y
			if check_X < 0 or check_X >= grid_size or check_Y < 0 or check_Y >= grid_size:
				return false
			if grid[check_Y][check_X] == 1:
				return false
	return true

## Checks if a 45x45 room can be placed
func can_place_room(X, Y) -> bool:
	if rooms <= 0:
		return false
	# Check 45x45 area
	for y in range(ROOM_TILES):
		for x in range(ROOM_TILES):
			var check_X = X + x
			var check_Y = Y + y
			if check_X < 0 or check_X >= grid_size or check_Y < 0 or check_Y >= grid_size:
				return false
			if grid[check_Y][check_X] == 1:
				return false
	return true

## Given a 45x45 room's top-left (X,Y) and an exit dir, finds the
## top-left 15x15 path tile coordinates just outside its door.
func get_path_pos_from_room(X, Y, exit_dir) -> Array:
	# Door offset is centered in the path, not the room
	var door_offset = int((ROOM_TILES - PATH_TILES) / 2.0) # (45 - 15) / 2 = 15
	
	if exit_dir == 0: # Exit NORTH
		return [X + door_offset, Y - PATH_TILES, 1] # Path top-left is at Y-15
	elif exit_dir == 1: # Exit SOUTH
		return [X + door_offset, Y + ROOM_TILES, 0] # Path top-left is at Y+45
	elif exit_dir == 2: # Exit EAST
		return [X + ROOM_TILES, Y + door_offset, 3] # Path top-left is at X+45
	else: # Exit WEST (3)
		return [X - PATH_TILES, Y + door_offset, 2] # Path top-left is at X-15

## Given a 15x15 path's top-left (X,Y) and the dir it came from,
## finds the top-left 45x45 room coordinates that would connect to it.
func get_room_pos_from_path(X, Y, came_from_dir) -> Array:
	var door_offset = int((ROOM_TILES - PATH_TILES) / 2.0) # 15
	
	if came_from_dir == 0: # Path came from NORTH (at Y-15)
		return [X - door_offset, Y + PATH_TILES] # Room top-left at (X-15, Y+15)
	elif came_from_dir == 1: # Path came from SOUTH (at Y+45)
		return [X - door_offset, Y - ROOM_TILES] # Room top-left at (X-15, Y-45)
	elif came_from_dir == 2: # Path came from EAST (at X+45)
		return [X - ROOM_TILES, Y - door_offset] # Room top-left at (X-45, Y-15)
	else: # Path came from WEST (3) (at X-15)
		return [X + PATH_TILES, Y - door_offset] # Room top-left at (X+15, Y-15)

## Given a 15x15 path's top-left (X,Y) and its type/dir,
## returns an array of its new exits (top-left coords)
func get_path_exits(X, Y, path_type, came_from_dir) -> Array:
	var exits = []
	
	# [next_X, next_Y, next_came_from_dir]
	# Each step is PATH_TILES (15) wide
	var north_exit = [X, Y - PATH_TILES, 1]
	var south_exit = [X, Y + PATH_TILES, 0]
	var east_exit =  [X + PATH_TILES, Y, 3]
	var west_exit =  [X - PATH_TILES, Y, 2]
	
	var all_dirs = [north_exit, south_exit, east_exit, west_exit]
	
	# 1: Straight
	if path_type == 1:
		if came_from_dir == 0: exits.append(south_exit)
		if came_from_dir == 1: exits.append(north_exit)
		if came_from_dir == 2: exits.append(west_exit)
		if came_from_dir == 3: exits.append(east_exit)
	
	# 3: T-Shape
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
			
	# 4: 4-Way
	elif path_type == 4:
		for i in range(4):
			if i != came_from_dir: 
				exits.append(all_dirs[i])
				
	return exits
