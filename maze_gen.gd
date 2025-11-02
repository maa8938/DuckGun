extends Container

const UNIT = 15
const RATIO = 3 # A room is 3x3 tiles
const PATH_SIZE = 1 # A path is 1x1 tile
# The "stride" is the full space one logical cell takes up (room + path)
const STRIDE = RATIO + PATH_SIZE # 3 + 1 = 4

var grid_dimension = 50
var rooms = 15
@onready var tilemap = $HedgeMazeMap
@onready var tileSet = tilemap.tile_set

var grid = []
var room_indexes = {
	1: [14, 8, 13, 12], 
	2: [7, 7, 9, 9], 
	3: [10, 17, 16, 15], 
	4: [11, 11, 11, 11]
}

var path_indexes = {
	0: [20, 6, 19, 21] # Basically a dead end
	1: [2, 2, 18, 18] # straight path
	2: [22, 24, 0, 23] # left turn
	3: [27, 25, 4, 26] # t shape
	4: [3, 3, 3, 3] # 4 way intersection
}

# --- !!! IMPORTANT !!! ---
# You must set this to the pattern index for your 1x1 path tile
const PATH_PATTERN_INDEX = 0 
var pathPattern

func _ready() -> void:
	# Get the path pattern from the tile set
	pathPattern = tileSet.get_pattern(PATH_PATTERN_INDEX)
	if not pathPattern:
		print_error("Path pattern not found! Check PATH_PATTERN_INDEX.")

	for i in range(grid_dimension):
		grid.append([])
		for j in range(grid_dimension):
			grid[-1].append(0)
			
	var X = int(grid_dimension / 2.0)
	var Y = grid_dimension - 1 
	var cur_dir = 1 
	create_room(X, Y, cur_dir)

func can_place_room(X, Y) -> bool:
	if rooms <= 0:
		return false
	if X < 0 or X >= grid_dimension or Y < 0 or Y >= grid_dimension:
		return false
	if grid[Y][X] == 1:
		return false
	return true

func create_room(X, Y, cur_dir_came_from):
	if not can_place_room(X, Y):
		return

	grid[Y][X] = 1
	rooms -= 1

	# --- 3. Place the Room Pattern ---
	var rand_enterances = randi_range(1, 4)
	var roomIndex = room_indexes[rand_enterances][cur_dir_came_from]
	var normalRoom = tileSet.get_pattern(roomIndex)
	
	# --- THIS IS THE FIX ---
	# We multiply by STRIDE (4) to leave a 1-tile gap for the path
	var tile_pos = Vector2i(X * STRIDE, Y * STRIDE)
	
	if normalRoom:
		tilemap.set_pattern(tile_pos, normalRoom)
	else:
		print_error("Room pattern not found for index: " + str(roomIndex))

	# --- 4. Recurse: Try to spread to neighbors ---
	if rooms <= 0:
		return

	var directions = [0, 1, 2, 3] # N, S, E, W
	directions.shuffle() 

	for dir in directions:
		var next_X = X
		var next_Y = Y
		var next_dir_came_from = -1 
		
		if dir == 0: # Try NORTH
			next_Y = Y - 1
			next_dir_came_from = 1 # Next room is entered from SOUTH
		elif dir == 1: # Try SOUTH
			next_Y = Y + 1
			next_dir_came_from = 0 # Next room is entered from NORTH
		elif dir == 2: # Try EAST
			next_X = X + 1
			next_dir_came_from = 3 # Next room is entered from WEST
		elif dir == 3: # Try WEST
			next_X = X - 1
			next_dir_came_from = 2 # Next room is entered from EAST

		# Check if the neighbor is a valid spot *before* placing a path
		if can_place_room(next_X, next_Y):
			
			# --- ADD THE PATH TILE ---
			# It's a valid new room, so place a 1x1 path to it.
			var path_pos = Vector2i()
			
			# Doors are in the middle of the 3x3 room, so at offset +1
			var door_offset = int(RATIO / 2.0) # 3 / 2 = 1
			
			if dir == 0: # Going NORTH
				# Path is *above* current room
				path_pos = Vector2i(tile_pos.x + door_offset, tile_pos.y - 1)
			elif dir == 1: # Going SOUTH
				# Path is *below* current room (at tile_pos.y + 3)
				path_pos = Vector2i(tile_pos.x + door_offset, tile_pos.y + RATIO)
			elif dir == 2: # Going EAST
				# Path is to the *right* of current room (at tile_pos.x + 3)
				path_pos = Vector2i(tile_pos.x + RATIO, tile_pos.y + door_offset)
			elif dir == 3: # Going WEST
				# Path is to the *left* of current room
				path_pos = Vector2i(tile_pos.x - 1, tile_pos.y + door_offset)

			if pathPattern:
				tilemap.set_pattern(path_pos, pathPattern)
			
			# Now, recursively create the next room
			create_room(next_X, next_Y, next_dir_came_from)
