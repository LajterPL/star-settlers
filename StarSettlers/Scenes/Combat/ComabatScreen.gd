extends CanvasLayer

signal character_clicked

@onready var visual_panel : Control = $VisualPanel/Characters
@export var combat_area_size : int = 12
@onready var icon_size : int

var characters : Dictionary = {}

@onready var game_info = get_node("/root/GameInfo")

@onready var description_label = $InfoPanel/OtherPanel/DescriptionLabel

@onready var shoot_button = $InfoPanel/ActionsPanel/ShootButton
@onready var light_attack_button = $InfoPanel/ActionsPanel/LightAttackButton
@onready var heavy_attack_button = $InfoPanel/ActionsPanel/HeavyAttackButton
@onready var walk_button = $InfoPanel/ActionsPanel/WalkButton
@onready var run_button = $InfoPanel/ActionsPanel/RunButton
@onready var action_buttons_group = shoot_button.button_group

var defense_mod : float = 0
var dodge_mod : float = 0
var dmg_recv_mod : float = 0

@export var defense_mod_boost : float = 0.2
@export var dodge_mod_boost : float = 0.2
@export var dmg_recv_mod_boost : float = 0.2

var last_clicked_character : Character

func _ready():
	icon_size = get_viewport().get_visible_rect().size.x / combat_area_size
	
	var enemy = load("res://Scenes/Combat/Character/test_enemy.tres")
	
	new_fight({enemy: 3})

func _input(event):
	if event is InputEventMouse:
		if event.button_mask == MOUSE_BUTTON_LEFT:
			
			for character in characters:
				
				var icon = characters[character][1].get_child(0)
				
				if icon.get_global_rect().has_point(event.position):
					last_clicked_character = character
					emit_signal("character_clicked")
					return
	if event is InputEventScreenTouch:
		if event.double_tap:
			for character in characters:
				
				var icon = characters[character][1].get_child(0)
				
				if icon.get_global_rect().has_point(event.position):
					last_clicked_character = character
					emit_signal("character_clicked")
					return

func new_fight(enemies : Dictionary = {}):
	
	set_description("Fight!")
	
	# Sprawdza czy gracz może stzrelać
	for item in game_info.player.equipment.items:
		if item.type == Item.ItemType.RANGED:
			shoot_button.disabled = false
	
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
		icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		
		if character != game_info.player:
			icon.flip_h = true
		
		container.add_child(icon)
		
		var health_bar : ProgressBar = ProgressBar.new()
		health_bar.size = Vector2(icon_size, 10)
		health_bar.position = Vector2(0, -20)
		health_bar.max_value = character.max_hp
		health_bar.value = character.current_hp
		health_bar.show_percentage = false
		health_bar.name = "HealthBar"
		
		container.add_child(health_bar)
		
		visual_panel.add_child(container)
		characters[character] = [characters[character], container]
		
	update_screen()
		
func _on_accept_turn_pressed():
	var action = action_buttons_group.get_pressed_button()
	
	if action == null:
		return
		
	var player_pos = characters[game_info.player][0]
	
	match action.name:
		"WalkButton":
			characters[game_info.player][0] += 1
			reset_mods()
		"RunButton":			
			characters[game_info.player][0] += 2
			reset_mods()
			dmg_recv_mod = dmg_recv_mod_boost
		"DefenseButton":
			reset_mods()
			defense_mod = defense_mod_boost
		"DodgeButton":
			reset_mods()
			dodge_mod = dodge_mod_boost
		"LightAttackButton":
			
			var target = find_character_at([player_pos + 1, player_pos - 1])
			
			if len(target) > 1:
				pass
			elif len(target) == 1:
				target = target[0]
			else:
				push_error("Player tried to attack, but there was no target")
				return
				
			melee_fight(game_info.player, target)
			reset_mods()
		"HeavyAttackButton":
			var target = find_character_at([player_pos + 1, player_pos - 1])
			
			if len(target) > 1:
				pass
			elif len(target) == 1:
				target = target[0]
			else:
				push_error("Player tried to attack, but there was no target")
				return
				
			melee_fight(game_info.player, target, 0, 0, 0.5, -0.1)
			reset_mods()
		"ShootButton":
			var target = await select_target()
			
			target.current_hp -= 1
		
	update_screen()
	
	for character in characters:
		if character.current_hp <= 0:
			characters[character][1].queue_free()
			characters.erase(character)
			
	update_screen()
	
func update_screen():
	
	#Rysowanie postaci
	for character in characters.keys():
		characters[character][1].position = Vector2(icon_size * characters[character][0], 
		(get_viewport().get_visible_rect().size.y / 4) - icon_size/2)
		
		
		characters[character][1].get_children()[1].value = character.current_hp
		
	var player_pos = characters[game_info.player][0]	
	
	if len(find_character_at([player_pos + 1, player_pos - 1])) == 0:
		light_attack_button.disabled = true
		heavy_attack_button.disabled = true
	else:
		light_attack_button.disabled = false
		heavy_attack_button.disabled = false
		
	if len(find_character_at([player_pos + 1])) == 0:
		walk_button.disabled = false
	else:
		walk_button.disabled = true
		
	if len(find_character_at([player_pos + 1, player_pos + 2])) == 0:
		run_button.disabled = false
	else:
		run_button.disabled = true
		
	if player_pos + 1 >= combat_area_size:
		walk_button.disabled = true
		run_button.disabled = true
	elif player_pos + 2 >= combat_area_size:
		run_button.disabled = true
		
func set_description(string : String):
	description_label.set_text(string)

func reset_mods():
	defense_mod = 0
	dodge_mod = 0
	dmg_recv_mod = 0
	
func find_character_at(positions : Array[int]):
	var found_targets = []
	
	for character in characters:
		if positions.has(characters[character][0]):
			found_targets.append(character)
			
	return found_targets
	
func select_target(targets : Array = characters.keys()):
	
	while true:
		set_description("Choose target.")
		await self.character_clicked
		if targets.has(last_clicked_character):
			return last_clicked_character
	
	
func melee_fight(attacker : Character, defender : Character, 
defense_mod : float = 0, dodge_mod : float = 0, dmg_recv_mod : float = 0,
hit_mod : float = 0):
	
	var weapon : Item = null
		
	for item in attacker.equipment.items:
		if item.type == Item.ItemType.MELEE:
			weapon = item
			break
	
	var dodge_roll = randi() % 30 + 10 * defender.agility
	var hit_roll = randi() % 30 + 10 * attacker.agility
	
	if weapon != null:
		hit_mod += weapon.values["hit_mod"]
	
	if dodge_roll + dodge_mod * dodge_roll < hit_roll + hit_mod * hit_roll:
		
		var dmg_roll = 1
		
		if weapon != null:
			
			var min_dmg = weapon.values["min_dmg"]
			var max_dmg = weapon.values["max_dmg"]
			
			dmg_roll = (randi() % (max_dmg - min_dmg)) + min_dmg
			
		dmg_roll *= attacker.strenght / 5.0
		dmg_roll -= dmg_roll * defense_mod
		dmg_roll += dmg_roll * dmg_recv_mod
		
		defender.current_hp -= dmg_roll
		
		set_description("%s hit %s for %d dmg!" % [attacker.name, defender.name, dmg_roll])
	else:
		set_description("%s missed %s!" % [attacker.name, defender.name])
		
func ranged_fight():
	pass

func _on_walk_button_pressed():
	set_description("Move 1 space forward")


func _on_run_button_pressed():
	set_description("Move 2 spaces forward. Easier to hit in melee next round.")


func _on_light_attack_button_pressed():
	set_description("Performs light attack. Bigger chance of hitting the target.")


func _on_heavy_attack_button_pressed():
	set_description("Performs heavy attack. More damage, but smaller chance of hitting the target.")


func _on_shoot_button_pressed():
	set_description("Shoot the target.")


func _on_defense_button_pressed():
	set_description("Prepare your defense. Defense boost for next round.")


func _on_dodge_button_pressed():
	set_description("Prepare for dodge. Less chance of getting hit.")


func _on_escape_button_pressed():
	set_description("Escape form fight.")



