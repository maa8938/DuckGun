extends Node

const horzlineIndex = 0
const cornerIndex = 2
const normalRoomIndex = 3
const RoomSize = 70
const midWallRoomIndex = 4;
const gridSize = 700

@onready var tilemap = $HedgeMazeMap

func _ready() -> void:
	# called whenever the object enters the scene
	
	# randomly generates 10 rooms with no intersection
	var tileSet = tilemap.tile_set
	var normalRoom = tileSet.get_pattern(normalRoomIndex)
	# array of used
	var roomArray = []
	var randX
	var randY
	var position
	var positionCheck
	
	for i in range(10):
		positionCheck = false
		while positionCheck == false:
			var isInRange = false
			randX = randi_range(-gridSize / 2, (gridSize / 2) - RoomSize)
			randY = randi_range(-gridSize / 2, (gridSize / 2) - RoomSize)
			position = Vector2i(randX, randY)
			for j in range(roomArray.size()):
				if position.x in roomArray.get(j).get(0) or position.y in roomArray.get(j).get(1):
					isInRange = true
					break
			if isInRange == false:
				positionCheck = true
				tilemap.set_pattern(position, normalRoom)
				roomArray.append([range(position.x, position.x + RoomSize), range(position.y, position.y + RoomSize)])
			# TODO: Change so it randomly picks between a random index of unique rooms
		
	# puts down a pattern
	print("RoomArray: ", roomArray)
	# tilemap.set_pattern(position, normalRoom)
