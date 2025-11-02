extends Container

const UNIT = 15
const PATH = UNIT
const RATIO = 3
const ROOM = RATIO * UNIT
var grid_size = UNIT * 50
var rooms = 15
@onready var tilemap = $HedgeMazeMap
@onready var tileSet = tilemap.tile_set

var grid = []
# {NUMBER OF ENTERANCES: [NORTH, SOUTH, EAST, WEST], ...}
var room_indexes = {1: [14, 8, 13, 12], 2: [7, 7, 9, 9], 3: [10, 17, 16, 15], 4: [11, 11, 11, 11]}


func create_path(X, Y):
	if grid[Y][X] == 1 or rooms <= 0:
		return false
	var rand_enterances = randi_range(1, 4)
	
	

func create_room(X, Y, cur_dir):
	if rooms <= 0:
		return
	var rand_enterances = randi_range(1, 4)
	var roomIndex = room_indexes[rand_enterances][cur_dir]
	var normalRoom = tileSet.get_pattern(roomIndex)
	tilemap.set_pattern(position, normalRoom)
	for x in range(-1, RATIO - 1):
		for y in range(-1, RATIO - 1):
			grid[Y+y][X+x] = 1
	rooms -= 1
	while create_path(X + 1, Y + 1):
		create_room(X + 1, Y + 1, 0)
	while create_path(X - 1, Y + 1):
		create_room(X - 1, Y + 1, 3)
	while create_path(X + 1, Y - 1):
		create_room(X + 1, Y - 1, 2)
	while create_path(X - 1, Y - 1):
		create_room(X - 1, Y - 1, 1)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(grid_size):
		grid.append([])
		for j in range(grid_size):
			grid[-1].append([0])
	var X = int(grid_size / 2.0)
	var Y = grid_size - 1
	# 0: NORTH, 1: SOUTH, 2: EAST, 3: WEST
	var cur_dir = 1
	create_room(X, Y, cur_dir)
	# while rooms > 0:
	# 	var rand_enterances = randi_range(1, 4)
	# 	var roomIndex = room_indexes[rand_enterances][cur_dir]
	# 	var normalRoom = tileSet.get_pattern(roomIndex)
	# 	tilemap.set_pattern(position, normalRoom)
	# 	for x in range(-1, RATIO - 1):
	# 		for y in range(-1, RATIO - 1):
	# 			grid[Y+y][X+x] = 1
	# 	rooms -= 1
	# 	var free_spots = 0
	# 	for i in [-RATIO, RATIO]:
	# 		for j in [-RATIO, RATIO]:
	# 			if grid[Y+i][X+j] == 0:
	# 				free_spots += 1
	# 	var rand_paths = randi_range(0, free_spots)
	# 	while rand_paths > 0:
	# 		rand_paths -= 1
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
