extends Node

const horzlineIndex = 0
const cornerIndex = 2
const normalRoomIndex = 3
const RoomSize = 60
const midWallRoomIndex = 4
const gridSize = 400
const grassTileID = 0
const numOfRooms = 15

@onready var tilemap = $HedgeMazeMap

func _ready() -> void:
	# called whenever the object enters the scene
	
	# randomly generates 20 rooms with no intersection
	var tileSet = tilemap.tile_set
	var normalRoom = tileSet.get_pattern(normalRoomIndex)
	var full = false
	
	
	# sets every tile to grass
	for i in range(gridSize):
		for j in range(gridSize):
			tilemap.set_cell(Vector2i(i - gridSize / 2, j - gridSize / 2), grassTileID, Vector2i(1, 0))
		
	# array of used
	var roomArray = []
	var randX
	var randY
	var position
	
	# --- FIX IS HERE ---
	# The grid max is (gridSize / 2) - 1. (e.g., 400 - 1 = 399)
	# The room's center must be (grid_max - half_room_size).
	# 399 - 30 = 369.
	var limit_right = (gridSize / 2.0) - 1.0 - (RoomSize)
	# The grid min is -(gridSize / 2). (e.g., -400)
	# The room's center must be (grid_min + half_room_size).
	# -400 + 30 = -370.
	var limit_left = -(gridSize / 2.0) + (RoomSize)
	# ---
	
	randX = (limit_right + limit_left) / 2.0
	randY = randX
	
	for i in range(numOfRooms):
		var positionCheck = false
		var attempts = 0
		
		# We need a true failsafe in case the "desperation" linear scan
		# also fails, to prevent a 100% infinite loop.
		var max_grid_scans = (gridSize * gridSize) + 100 # A reasonable max
		var desperation_attempts = 0

		# "Keep trying UNTIL positionCheck is true."
		while (not positionCheck) and (not full):
			if attempts <= 10:
				randX = randi_range(limit_left, limit_right)
				randY = randi_range(limit_left, limit_right)
				attempts += 1
			else:
				# This is your "desperation mode" linear scan
				randX += 1
				if randX > limit_right:
					randX = limit_left
					randY += 1
				if randY > limit_right:
					# This means we've scanned the whole map and found no spot.
					# We must stop the generation.
					print("ERROR: Scanned the entire map and could not place room ", i)
					full = true
					i = numOfRooms # This will break the outer 'for' loop
					break          # This breaks the inner 'while' loop
				
				# Failsafe check
				desperation_attempts += 1
				if desperation_attempts > max_grid_scans:
					print("ERROR: Failsafe triggered. Stopping generation.")
					i = numOfRooms
					break

			position = Vector2i(randX, randY)

			# Define the bounds for the NEW room we are trying to place
			var new_x1 = position.x - RoomSize / 2
			var new_x2 = position.x + RoomSize / 2
			var new_y1 = position.y - RoomSize / 2
			var new_y2 = position.y + RoomSize / 2
			
			var isOverlapping = false
			
			for j in range(roomArray.size()):
				var currentRoom = roomArray.get(j)
				
				# Correct AABB Overlap Check
				# We overlap if we overlap on X *AND* we overlap on Y.
				
				var x_overlaps = (new_x1 < currentRoom["x2"] and new_x2 > currentRoom["x1"])
				var y_overlaps = (new_y1 < currentRoom["y2"] and new_y2 > currentRoom["y1"])
				
				if x_overlaps and y_overlaps:
					isOverlapping = true
					break # Found an overlap, stop checking other rooms
			
			# If we went through all rooms and found NO overlaps
			if isOverlapping == false:
				positionCheck = true # We found a valid spot!
				tilemap.set_pattern(position, normalRoom)
				# Add the new room's bounds to our array
				roomArray.append({"x1": new_x1, "x2": new_x2, "y1": new_y1, "y2": new_y2})
		
	print("RoomArray: ", roomArray)
	print("Successfully placed ", roomArray.size(), " rooms.")
