extends CanvasLayer

@onready var starting_faction : Array = []
var faction_index = 0

@onready var faction_logo : TextureRect = $FactionSelection/FactionLogo
@onready var faction_name : Label = $FactionSelection/HBoxContainer/FactionName
@onready var faction_name2 : Label = $ScrollContainer/FactionDetails/FactionName
@onready var faction_description : Label = $ScrollContainer/FactionDetails/FactionDescription

func _ready():
	starting_faction.append(load("res://Resources/Faction/Dingo.tres") as Faction)
	starting_faction.append(load("res://Resources/Faction/VCorp.tres") as Faction)
	starting_faction.append(load("res://Resources/Faction/Walrus.tres") as Faction)
	
	show_faction()

func show_faction():
	var faction = starting_faction[faction_index]
	
	faction_logo.texture = faction.icon
	faction_name.text = faction.name
	faction_name2.text = faction.name
	faction_description.text = faction.description


func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/Main Menu/MainMenu.tscn")


func _on_confirm_button_pressed():
	
	GameInfo.set_player(starting_faction[faction_index].starting_character)
	
	get_tree().change_scene_to_file("res://Scenes/Map/test_map.tscn")


func _on_prev_faction_button_pressed():
	faction_index -= 1
	
	if faction_index < 0:
		faction_index = starting_faction.size() - 1
		
	show_faction()


func _on_next_faction_button_pressed():
	faction_index += 1
	
	if faction_index == starting_faction.size():
		faction_index = 0
		
	show_faction()
