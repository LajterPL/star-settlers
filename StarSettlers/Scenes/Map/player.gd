extends Node2D
@onready var tile_map = $"../TileMap"
var ground_layer = 0

func _ready():
	pass 


func _process(_delta):
	pass

func _input(_event):
	#po kliknięciu zmienia pozycję gracza na pozycję wciśniętego kafelka
	if Input.is_action_just_pressed("click"):
		var mouse_position = get_global_mouse_position()
		var tile_position = tile_map.local_to_map(mouse_position)
		var tile_data = tile_map.get_cell_tile_data(ground_layer,tile_position,false)
		if tile_data.get_custom_data("walkable"):
			global_position = tile_map.map_to_local(tile_position)
		print("tile_map_position: ", tile_position)
		print("tile_local_position: ", tile_map.map_to_local(tile_position))
		
