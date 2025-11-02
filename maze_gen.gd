extends Container

const UNIT = 15
const PATH = UNIT
const RATIO = 3
const ROOM = RATIO * UNIT
var grid_size = UNIT * 50
var rooms = 15

var grid = []
var room_indexes = {1: [14, 8, 13, 12], 2: [7, 7, 9, 9], 3: [10, 17, 16, 15], 4: [11, 11, 11, 11]}

@onready var tilemap = $HedgeMazeMap

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var tileSet = tilemap.tile_set

	for i in range(grid_size):
		grid.append([])
		for j in range(grid_size):
			grid[-1].append(["EMPTY"])
	var randX = int(grid_size / 2)
	var randY = grid_size - 1
	for room_id in range(rooms):
		# var roomIndex = rand
		var normalRoom = tileSet.get_pattern(roomIndex)
		tilemap.set_pattern(position, normalRoom)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
