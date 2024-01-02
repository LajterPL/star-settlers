extends TileMap
@onready var player = $"../Player"
var ground_layer = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func a_star_path(start: Vector2i, target: Vector2i):
	var open_set = []
	var closed_set = []
	var came_from = {}
	var g_score = {}
	var f_score = {}
	
	open_set.append(start)
	g_score[start] = 0
	f_score[start] = heuristic(start, target)
	
	while open_set.size() > 0:
		var current = get_lowest_f_score(open_set, f_score)
		if current == target:
			return reconstruct_path(came_from, current)
			
		open_set.erase(current)
		closed_set.append(current)
		
		for neighbor in get_neighbors(current):
			var tile_data = get_cell_tile_data(ground_layer,neighbor,false)
			if tile_data != null:
				if  closed_set.find(neighbor) != -1 or !tile_data.get_custom_data("walkable"):
					continue
				var tentative_g_score = g_score[current] + tile_data.get_custom_data("difficult_terrain")
				
				if open_set.find(neighbor) == -1 or tentative_g_score < g_score[neighbor]:
					came_from[neighbor] = current
					g_score[neighbor] = tentative_g_score
					f_score[neighbor] = tentative_g_score + heuristic(neighbor, target)
					
					if open_set.find(neighbor) == -1:
						open_set.append(neighbor)
	return []
			
			
func heuristic(start: Vector2i,target: Vector2i):
	var distance = ((start.x-target.x)**2+(start.y-target.y)**2)**-2
	return -distance	
	
func get_lowest_f_score(open_set, f_score):
	var lowest = open_set[0]
	for elem in open_set:
		if f_score[elem] < f_score[lowest]:
			lowest = elem
	return lowest
	
func reconstruct_path(came_from, current: Vector2i):
	var path: Array[Vector2i] = []
	var next = came_from.get(current)
	path.append(current)
	while next != null:
		path.append(next)
		next = came_from.get(next)
	path.reverse()
	return path

func get_point_path(path: Array[Vector2i]):
	var point_path: Array[Vector2] = []
	point_path.append(player.global_position)
	for vec in path:
		point_path.append(map_to_local(vec))
	return PackedVector2Array(point_path)

func get_neighbors(current: Vector2i):
	#nie wiem jak to zrobić inaczej ważne że działa ok?
	#var neighbors_positions = []
	#neighbors_positions.append(get_neighbor_cell(current,TileSet.CELL_NEIGHBOR_TOP_LEFT_SIDE))
	#neighbors_positions.append(get_neighbor_cell(current,TileSet.CELL_NEIGHBOR_TOP_RIGHT_SIDE))
	#neighbors_positions.append(get_neighbor_cell(current,TileSet.CELL_NEIGHBOR_BOTTOM_LEFT_SIDE))
	#neighbors_positions.append(get_neighbor_cell(current,TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_SIDE))
	#neighbors_positions.append(get_neighbor_cell(current,TileSet.CELL_NEIGHBOR_LEFT_SIDE))
	#neighbors_positions.append(get_neighbor_cell(current,TileSet.CELL_NEIGHBOR_RIGHT_SIDE))		
	var neighbors_positions = get_surrounding_cells(current)
	
	return neighbors_positions

