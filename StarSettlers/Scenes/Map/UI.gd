extends CanvasLayer

# Deklaracja zmiennej przechowującej nową scenę
var buildings_menu_scene = preload("res://Scenes/Build Menu/BuildMenu.tscn")

# Funkcja wywoływana przy naciśnięciu guzika
func _on_button_3_pressed():
	var new_scene_instance = buildings_menu_scene.instantiate()
	add_child(new_scene_instance)
	
	new_scene_instance.connect("building_chosen", _on_building_chosen)
	
func _on_building_chosen(option):
	var tilemap = get_node("../../TileMap")
	tilemap.create_building(option)
