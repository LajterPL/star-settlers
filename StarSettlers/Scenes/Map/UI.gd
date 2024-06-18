extends CanvasLayer

@onready var menu_buttons : HBoxContainer = $MenuButtons
@onready var chat_button : Button = $ChatButton

@onready var talk_range : Area2D = $"../../Player/TalkRange"
@onready var player = $"../../Player"

var target_npc = null

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
	chat_button.hide()

func _on_eq_closed():
	menu_buttons.show()
	
func _process(delta):
	
	# Wykrywanie NPC w pobliżu
	var bodies : Array[Node2D] = talk_range.get_overlapping_bodies()
	
	bodies = bodies.filter(func(a): return a.name.contains("NPC"))
	
	# Jeśli ich nie ma, ukryj guzik
	if bodies.size() <= 0:
		chat_button.hide()
		return
	
	bodies.sort_custom(sort_by_distance)
	
	target_npc = bodies[0]
	
	if not target_npc.is_chatting:
		chat_button.show()
		menu_buttons.show()
		
		player.is_chatting = false
		
	
func sort_by_distance(a : Node2D, b : Node2D):
	var player_pos = player.global_position
	
	return a.global_position.distance_to(player_pos) < b.global_position.distance_to(player_pos)


func _on_chat_button_pressed():
	chat_button.hide()
	menu_buttons.hide()
	
	target_npc.chat()
	
	player.is_chatting = true
