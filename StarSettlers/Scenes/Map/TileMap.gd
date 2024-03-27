extends TileMap
@onready var player = $"../Player"
# id warstwy podłoża
var ground_layer = 0
var map_size = Vector2i(150,150)
# dystans od środka mapy w jakim rozpoczynam generacje innych biomów
var radius = map_size.x/4 

func _ready():
	generate_bioms_layout()

## główna funkcja generowania mapy
## iteruje po cistach krawędzi i wypełnia tak długo jak ma miejsce
## biom początkowy dodatkowo ograniczam dystansem
func generate_bioms_layout():
	var number_of_bioms = 5
	var biom_start_positions = biom_start_points(number_of_bioms)
	var fill_counter = map_size.x * map_size.y
	var biom_pointer = 0
	var edges = []

	for i in range(0, number_of_bioms + 1):
		edges.append([])
		edges[i].append(biom_start_positions[i])

	while fill_counter > 0:
		if edges[biom_pointer].size() > 0:
			var tile_index = randi() % edges[biom_pointer].size()
			
			if not (biom_pointer == 0 and
					vec_distance(edges[biom_pointer][tile_index],
								 Vector2i(int(map_size.x / 2), int(map_size.y / 2))) > radius
			):
				edges[biom_pointer] = set_empty_neighbours(
					tile_index, edges[biom_pointer],
					Vector2i(randi() % 4, biom_pointer)
				)

		fill_counter -= 1
		biom_pointer = (biom_pointer + 1) % (number_of_bioms + 1)


func vec_distance(a: Vector2i, b: Vector2i):
	return sqrt(pow((a.x - b.x), 2) + pow((a.y - b.y), 2))

## ustawi pustych sąsiadów komórki jako kafelek o podanym kolorze
## i dopisuje do listy krawędzi biomu
func set_empty_neighbours(tile_index: int, biom_edge_set, biom_colour):
	var tile = biom_edge_set[tile_index]
	biom_edge_set.erase(tile)

	for neighbor in get_surrounding_cells(tile):
		if (
			get_cell_tile_data(ground_layer, neighbor) == null
			and neighbor.x > 0
			and neighbor.y > 0
			and neighbor.x < map_size.x
			and neighbor.y < map_size.y
		):
			set_cell(ground_layer, neighbor, 3, biom_colour)
			biom_edge_set.append(neighbor)

	for elem in biom_edge_set:
		var covered = true
		for neighbor in get_surrounding_cells(elem):
			if get_cell_tile_data(ground_layer, neighbor) == null:
				covered = false
				break

		if covered:
			biom_edge_set.erase(elem)

	return biom_edge_set

## ustawia koordynasy punktów rozpoczącia generacji biomów
func biom_start_points(number_of_bioms: int):
	var biom_start_positions = []
	var center = Vector2i(int(map_size.x / 2), int(map_size.y / 2))
	biom_start_positions.append(center)

	var base_angle = 10
	var angle = randi()

	for point in range(0, number_of_bioms):
		angle += base_angle
		var x = int(center.x + radius * cos(angle))
		var y = int(center.y + radius * sin(angle))
		biom_start_positions.append(Vector2i(x, y))

	return biom_start_positions


	
func a_star_path(start: Vector2i, target: Vector2i):
	var open_set = []
	var closed_set = []
	var came_from = {}
	var g_score = {}
	var f_score = {}
	
	open_set.append(start)
	g_score[start] = 0
	f_score[start] = heuristic(start, target)
	
	var target_walkable = get_cell_tile_data(ground_layer, target, false).get_custom_data("walkable")
	
	while open_set.size() > 0:
		var current = get_lowest_f_score(open_set, f_score)
		if (target_walkable and (current == target)) or (!target_walkable and current in get_surrounding_cells(target)):
			return reconstruct_path(came_from, current)
			
		open_set.erase(current)
		closed_set.append(current)
		
		var neighbors_positions = get_surrounding_cells(current)
		for neighbor in neighbors_positions:
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
	var distance = sqrt((start.x-target.x)**2+(start.y-target.y)**2)
	return distance
	
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
