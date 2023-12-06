extends Node2D
@onready var tile_map = $"../TileMap"
var ground_layer = 0
var current_path: Array[Vector2i]

func _input(_event):
	if Input.is_action_just_pressed("click"):
		var mouse_position = get_global_mouse_position()
		var tile_position = tile_map.local_to_map(mouse_position)
		var tile_data = tile_map.get_cell_tile_data(ground_layer,tile_position,false)
		if tile_data != null and tile_data.get_custom_data("walkable"):
			var path = tile_map.a_star_path(
				tile_map.local_to_map(global_position),
				tile_map.local_to_map(mouse_position)
				).slice(1)
			print(path)
			
			if path.is_empty() == false:
				current_path = path
				
func _physics_process(_delta):
	if current_path.is_empty():
		return
	var target_position = tile_map.map_to_local(current_path.front())
	
	global_position = global_position.move_toward(target_position, 1)
	
	if global_position == target_position:
		current_path.pop_front()
		
	
		
		#print("tile_map_position: ", tile_position)
		#print("tile_local_position: ", tile_map.map_to_local(tile_position))
		
