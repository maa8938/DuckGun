extends Node

const horzlineIndex = 0
const cornerIndex = 2
const normalRoomIndex = 3
const midWallRoomIndex = 4;


func _ready() -> void:
	# called whenever the object enters the scene
	
	# randomly generates 
	var map = $HedgeMazeMap.get_script()
	
	var pattern = map.getTileSet()
	
	# place 10 random rooms around the area
		# make sure that there's no intersection
	# var normRoom = map.get_pattern(normalRoomIndex)
