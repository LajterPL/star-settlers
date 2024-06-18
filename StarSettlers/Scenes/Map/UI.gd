extends CanvasLayer

@onready var menu_buttons : HBoxContainer = $MenuButtons
@onready var chat_button : Button = $ChatButton

@onready var talk_range : Area2D = $"../../Player/TalkRange"
@onready var player = $"../../Player"

var show_ui = true

var target_npc = null

# Deklaracja zmiennej przechowującej nową scenę
var buildings_menu_scene = preload("res://Scenes/Build Menu/BuildMenu.tscn")
var equipment_menu_scene = preload("res://Scenes/Equipment/EquipmentTransferUI.tscn")
var base_menu_scene = preload("res://Scenes/Base Menu/BaseOverview.tscn")

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
	
	show_ui = false

func _on_eq_closed():
	show_ui = true
	
func _process(delta):
	
	menu_buttons.visible = show_ui
	
	if player.is_chatting:
		return
		
	# Wykrywanie NPC w pobliżu
	var bodies : Array[Node2D] = talk_range.get_overlapping_bodies()
	
	bodies = bodies.filter(func(a): return a.name.contains("NPC"))
	
	# Jeśli ich nie ma, ukryj guzik
	if bodies.size() <= 0:
		chat_button.hide()
		return
	
	bodies.sort_custom(sort_by_distance)
	
	target_npc = bodies[0]
	
	chat_button.visible = show_ui
	
func sort_by_distance(a : Node2D, b : Node2D):
	var player_pos = player.global_position
	
	return a.global_position.distance_to(player_pos) < b.global_position.distance_to(player_pos)

func _on_chat_button_pressed():
	chat_button.hide()
	menu_buttons.hide()
	
	target_npc.chat()
	
	target_npc.connect("dialog_ended", _on_chat_closed)
	
	player.is_chatting = true
	show_ui = false

func _on_chat_closed():
	show_ui = true
	player.is_chatting = false

func _on_base_pressed():
	var base_menu = base_menu_scene.instantiate()
	add_child(base_menu)
	
	base_menu.connect("exited", _on_base_exited)
	
	chat_button.hide()
	menu_buttons.hide()
	
	show_ui = false
	player.is_chatting = true
	
func _on_base_exited():
	
	menu_buttons.show()
	
	show_ui = true
	player.is_chatting = false
	
