extends Node2D
@onready var tile_map = $"../TileMap"
var ground_layer = 0
var current_path: Array[Vector2i]
var current_point_path: PackedVector2Array
var target_position: Vector2
var is_moving: bool

@onready var drag_timer = $dragTimer
var click_position

@onready var player_camera = $"../PlayerCamera"

func _unhandled_input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			drag_timer.start(0.15)
			click_position = event.position
		else:
			if not drag_timer.is_stopped():
				var distance_between = click_position - event.position
				if distance_between < Vector2(5, 5) and distance_between > Vector2(-5, -5):
					# Sprawdzenie czy ma wrócić do gracza przy ruchu
					if player_camera.move_to_player_on_movement:
						player_camera.global_position = global_position
					
					var touch_position = position - ((get_global_transform_with_canvas().origin - event.position) / player_camera.zoom.x)
					var tile_position = tile_map.local_to_map(touch_position)
					var tile_data = tile_map.get_cell_tile_data(ground_layer,tile_position,false)
					if tile_data != null and tile_data.get_custom_data("walkable"):
						var path
						if is_moving:
							path = tile_map.a_star_path(
								tile_map.local_to_map(target_position),
								tile_map.local_to_map(touch_position)
								)
						else:
							path = tile_map.a_star_path(
							tile_map.local_to_map(global_position),
							tile_map.local_to_map(touch_position)
							).slice(1)
							
						if path.is_empty() == false:
							current_path = path
							current_point_path = tile_map.get_point_path(path)
				
func _physics_process(_delta):
	if current_path.is_empty():
		return
		
	if is_moving == false:
		target_position = tile_map.map_to_local(current_path.front())
		is_moving = true
	
	# Sprawdzenie czy kamera jest na graczu z możliwością niewielkiego błędu
	var distance_between_camera_and_player = player_camera.global_position.distance_squared_to(global_position)
	if distance_between_camera_and_player < 500:
		player_camera.global_position = global_position
	global_position = global_position.move_toward(target_position, 1.75)
	
	if global_position == target_position:
		current_path.pop_front()

		if current_path.is_empty() == false:
			target_position = tile_map.map_to_local(current_path.front())
		else:
			is_moving = false
