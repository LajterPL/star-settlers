extends CanvasLayer

@onready var visual_panel : Control = $VisualPanel
@export var combat_area_size : int = 10
@onready var icon_size : int

var characters : Dictionary = {}

@onready var game_info = get_node("/root/GameInfo")

func _ready():
	icon_size = get_viewport().get_visible_rect().size.x / combat_area_size
	new_fight()

func new_fight(enemies : Dictionary = {}):
	
	# Tworzy nową listę postaci
	self.characters = {}
	self.characters[game_info.player] = 0
	self.characters.merge(enemies)
	
	# Tworzenie wizualizacji postaci na polu walki
	for node in visual_panel.get_children():
		visual_panel.remove_child(node)
		node.queue_free()
	
	for character in self.characters.keys():	
		var container : Control = Control.new()
		container.position = Vector2(icon_size * characters[character], 
		(get_viewport().get_visible_rect().size.y / 4) - icon_size/2)
		
		var icon : TextureRect = TextureRect.new()
		icon.expand_mode = TextureRect.EXPAND_FIT_HEIGHT_PROPORTIONAL
		icon.size = Vector2(icon_size, icon_size)
		icon.texture = (character as Character).icon
		
		container.add_child(icon)
		
		var health_bar : ProgressBar = ProgressBar.new()
		health_bar.size = Vector2(icon_size, 10)
		health_bar.position = Vector2(0, -20)
		health_bar.max_value = character.max_hp
		health_bar.value = character.current_hp
		health_bar.show_percentage = false
		
		container.add_child(health_bar)
		
		visual_panel.add_child(container)
		characters[character] = [characters[character], container]
		
func update_combat_area():
	for value in characters.values():
		value[1].position = Vector2(icon_size * value[0], 
		(get_viewport().get_visible_rect().size.y / 4) - icon_size/2)
