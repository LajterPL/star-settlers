extends Node2D

@onready var tile_map = $"../TileMap"
@onready var animation_player = $AnimationPlayer
var ground_layer = 0
var current_path: Array[Vector2i]
var current_point_path: PackedVector2Array
var target_position: Vector2
var is_moving: bool
var faceing_right: bool
var is_chatting: bool = false

@onready var drag_timer = $dragTimer
var click_position

@onready var player_camera = $"../PlayerCamera"

var border_width = 30
var teleport_margin = 12

func _unhandled_input(event):
	if is_chatting:
		return

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
					var tile_data = tile_map.get_cell_tile_data(ground_layer, tile_position, false)
					var can_stand_near = false
					for cell in tile_map.get_surrounding_cells(tile_position):
						if tile_map.get_cell_tile_data(ground_layer, cell, false) != null and tile_map.get_cell_tile_data(ground_layer, cell, false).get_custom_data("walkable"):
							can_stand_near = true
					if tile_data != null and tile_data.get_custom_data("walkable") or can_stand_near:
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

	# sprawdzam kierunek gracza by dostosować animację
	is_moving = true
	target_position = tile_map.map_to_local(current_path.front())
	faceing_right = position.x - target_position.x < 0
	if faceing_right:
		$PlayerSprite.flip_h = false
	else:
		$PlayerSprite.flip_h = true
	animation_player.play("walking")

	# Sprawdzenie czy kamera jest na graczu z możliwością niewielkiego błędu
	var distance_between_camera_and_player = player_camera.global_position.distance_squared_to(global_position)
	if distance_between_camera_and_player < 500:
		player_camera.global_position = global_position
	global_position = global_position.move_toward(target_position, 1.75)

	if global_position == target_position:
		current_path.pop_front()

		if current_path.is_empty():
			# gdy pezestaje iść kończe animacje
			is_moving = false
			animation_player.play("Idle")
	
	# Sprawdzenie czy gracz wyszedł poza mapę
	check_teleport()

func check_teleport():
	var map_size = tile_map.map_size
	# tutaj  na minusie bo w ukladzie wspolzednych godota to wystaje na minus
	var map_bounds_min = tile_map.map_to_local(Vector2i(-teleport_margin,-teleport_margin))
	var map_bounds_max = tile_map.map_to_local(Vector2i(map_size.x+teleport_margin,
														map_size.y+teleport_margin))
	
	
	if position.x < map_bounds_min.x:
		position.x = map_bounds_max.x
		clear_path_after_teleport()
	if position.x > map_bounds_max.x:
		position.x = map_bounds_min.x
		clear_path_after_teleport()
	if position.y < map_bounds_min.y:
		position.y = map_bounds_max.y
		clear_path_after_teleport()
	if position.y > map_bounds_max.y:
		position.y = map_bounds_min.y
		clear_path_after_teleport()
	
func clear_path_after_teleport():
	player_camera.global_position = global_position
	current_path = []
	current_point_path = []
	is_moving = false
	animation_player.play("Idle")
