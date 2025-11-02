extends Node

const horzlineIndex = 0
const cornerIndex = 2
const normalRoomIndex = 3
const RoomSize = 60
const midWallRoomIndex = 4
const gridSize = 900
const grassTileID = 0
const numOfRooms = 15

@onready var tilemap = $HedgeMazeMap

func _ready() -> void:
	# called whenever the object enters the scene
	
	# randomly generates 20 rooms with no intersection
	var tileSet = tilemap.tile_set
	var normalRoom = tileSet.get_pattern(normalRoomIndex)
	
	# sets every tile to grass
	for i in range(gridSize):
		for j in range(gridSize):
			tilemap.set_cell(Vector2i(i - (gridSize / 2), j - (gridSize / 2)), grassTileID, Vector2i(1, 0))
		
	# array of used
	var roomArray = []
	var randX
	var randY
	var position
	var positionCheck
	var rangeSize = (gridSize / 2 / RoomSize)
	
	for i in range(numOfRooms):
		positionCheck = false
		while positionCheck == false:
			var isInRange = false
			randX = RoomSize * randi_range(-rangeSize, rangeSize)
			randY = RoomSize * randi_range(-rangeSize, rangeSize)
			position = Vector2i(randX, randY)
			for j in range(roomArray.size()):
				var currentRoom = roomArray.get(j)
				if (position.x > currentRoom["x1"] and position.x < currentRoom["x2"]) or (position.y > currentRoom["y1"] and position.y < currentRoom["y2"]): 
					isInRange = true
					break
			if isInRange == false:
				positionCheck = true
				tilemap.set_pattern(position, normalRoom)
				roomArray.append({"x1": position.x - RoomSize / 2, "x2": position.x + RoomSize / 2, "y1": position.y - RoomSize / 2, "y2": position.y + RoomSize / 2})
			# TODO: Change so it randomly picks between a random index of unique rooms
		
	# puts down a pattern
	print("RoomArray: ", roomArray)
	# tilemap.set_pattern(position, normalRoom)
