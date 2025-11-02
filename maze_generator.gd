extends Node

const horzlineIndex = 0
const cornerIndex = 2
const normalRoomIndex = 3
const RoomSize = 60
const midWallRoomIndex = 4
const gridSize = 800
const grassTileID = 0
const numOfRooms = 30

@onready var tilemap = $HedgeMazeMap

func _ready() -> void:
	# called whenever the object enters the scene
	
	# randomly generates 20 rooms with no intersection
	var tileSet = tilemap.tile_set
	
	# sets every tile to grass
	for i in range(gridSize):
		for j in range(gridSize):
			tilemap.set_cell(Vector2i(i - 350, j - 350), grassTileID, Vector2i(1, 0))
		
	# array of used
	var roomArray = []
	var randX
	var randY
	var position
	var positionCheck
	
	for i in range(numOfRooms):
		positionCheck = false
		while positionCheck == false:
			var isInRange = false
			randX = randi_range(-gridSize / 2 + RoomSize / 2, (gridSize / 2) - RoomSize / 2)
			randY = randi_range(-gridSize / 2 + RoomSize / 2, (gridSize / 2) - RoomSize / 2)
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
