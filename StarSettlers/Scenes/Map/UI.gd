extends CanvasLayer

@onready var menu_buttons : HBoxContainer = $MenuButtons

# Deklaracja zmiennej przechowującej nową scenę
var buildings_menu_scene = preload("res://Scenes/Build Menu/BuildMenu.tscn")
var equipment_menu_scene = preload("res://Scenes/Equipment/EquipmentTransferUI.tscn")

# Funkcja wywoływana przy naciśnięciu guzika
func _on_button_3_pressed():
	var new_scene_instance = buildings_menu_scene.instantiate()
	add_child(new_scene_instance)
	
	new_scene_instance.connect("building_chosen", _on_building_chosen)
	
func _on_building_chosen(option):
	var tilemap = get_node("../../TileMap")
	tilemap.create_building(option)

func _on_eq_button_pressed():
	var new_scene_instance = equipment_menu_scene.instantiate()	
	add_child(new_scene_instance)
	
	new_scene_instance.load_equipment(null, GameInfo.player.equipment)
	
	new_scene_instance.connect("back_pressed", _on_eq_closed)
	
	menu_buttons.hide()

func _on_eq_closed():
	menu_buttons.show()
