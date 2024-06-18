extends TileMap
@onready var player = $"../Player"
@onready var materials_ui = $"../PlayerCamera/UI/MaterialsUI"
@onready var oxygen = $"../PlayerCamera/UI/MaterialsUI/Oxygen"
@onready var water = $"../PlayerCamera/UI/MaterialsUI/Water"
@onready var electr = $"../PlayerCamera/UI/MaterialsUI/Electricity"
@onready var steel = $"../PlayerCamera/UI/MaterialsUI/Steel"
@onready var building_sound = $BuildingSound

# id warstwy podłoża
var ground_layer = 0
var map_size = Vector2i(150,150)
# dystans od środka mapy w jakim rozpoczynam generacje innych biomów
var radius = map_size.x/4 

func _ready():
	GameInfo.map = self
	
	generate_bioms_layout()
	add_border(Vector2i(4, 1), 30)

		

## główna funkcja generowania mapy
## iteruje po polach krawędzi i wypełnia tak długo jak ma miejsce
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
					Vector2i(weighted_random_0_3(), biom_pointer)
				)

		fill_counter -= 1
		biom_pointer = (biom_pointer + 1) % (number_of_bioms + 1)
	
# dodawanie ramki
func add_border(border_tile, border_width: int):
	for x in range(0, map_size.x + 2* border_width):
		for y in range(0, map_size.y + 2* border_width):
			if x <= border_width or x >= border_width + map_size.x or y <= border_width or y >= border_width + map_size.y:
				set_cell(ground_layer, Vector2i(x - border_width, y - border_width), 3, border_tile)
				#set_cell(ground_layer, neighbor, 3, biom_colour)

func weighted_random_0_3():
	var rand_val = randf()
	if rand_val < 0.75:
		return 0
	elif rand_val < 0.97:
		return 1
	elif rand_val < 0.99:
		return 2
	else:
		return 3

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
	
func take_materials(oxygen_count, steel_count, electr_count, water_count):
	var ox = int(oxygen.text)
	var ste = int(steel.text)
	var elec = int(electr.text)
	var wat = int(water.text)
	ox -= oxygen_count
	ste -= steel_count
	elec -= electr_count
	wat -= water_count
	
	if (ox >= 0 and ste >= 0 and elec >= 0 and wat >= 0):
		oxygen.text = str(ox)
		steel.text = str(ste)
		electr.text = str(elec)
		water.text = str(wat)
		return true
	return false

func create_building(option):
	var building_tile = Vector2i(1, 1)
	var player_position = player.global_position
	var tilemap_position = local_to_map(player_position)
	
	var target_walkable = get_cell_tile_data(ground_layer, tilemap_position, false).get_custom_data("walkable")
	
	if target_walkable:
		if option == "PowerPlant":
			if take_materials(15, 20, 5, 25):
				building_tile = Vector2i(3, 1)
				materials_ui.electr_gain += 5
				set_cell(ground_layer, tilemap_position, 1, building_tile)
				building_sound.play()
		elif option == "SteelManufactory":
			if take_materials(15, 5, 50, 25):
				building_tile = Vector2i(5, 1)
				materials_ui.steel_gain += 5
				set_cell(ground_layer, tilemap_position, 1, building_tile)
				building_sound.play()
		elif option == "WaterPurifier":
			if take_materials(5, 20, 15, 25):
				building_tile = Vector2i(7, 1)
				materials_ui.water_gain += 5
				set_cell(ground_layer, tilemap_position, 1, building_tile)
				building_sound.play()
		elif option == "OxygenTank":
			if take_materials(15, 35, 5, 5):
				building_tile = Vector2i(9, 1)
				materials_ui.oxygen_gain += 5
				set_cell(ground_layer, tilemap_position, 1, building_tile)
				building_sound.play()
				
