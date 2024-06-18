extends CanvasLayer

## Wskaźniki na zakładki w menu
@onready var tabs : Array[Control] = [$Panel/OverviewPanel, $Panel/StoragePanel, $Panel/ResearchPanel, $Panel/CommsPanel]

## Timer określający maksymalny odstęp czasowy między kliknięciami 
@onready var double_click_timer : Timer = $DoubleClickTimer
var last_click_container_flag : bool = false ## Flaga określająca która lista została ostatnio kliknięta
var last_click_index : int = 0 ## Indeks ostatniego klikniętego przedmiotu
var base_equipment : Equipment
var player_equipment : Equipment


func _ready():
	load_resource_info([1, 1, 1, 1], [1, 1, 1, 1], [1, 1, 1, 1])
	
	var eq1 = Equipment.new(4)
	var eq2 = Equipment.new(4)
	
	eq1.transfer_item(Item.new(&"Patyk", "", load("res://icon.svg")))
	eq1.transfer_item(Item.new(&"Kamień", "", load("res://icon.svg")))
	eq1.transfer_item(Item.new(&"Karabin laserowy", "", load("res://icon.svg")))
	eq2.transfer_item(Item.new(&"Apteczka", "", load("res://icon.svg")))
	eq2.transfer_item(Item.new(&"Racja żywnościowa", "", load("res://icon.svg")))
	
	load_equipment(eq1, eq2)
	
	set_current_research_progress(50)
	
	set_current_research_details("Solar Power", "Building Unlocked: Solar Power Plant")
	
	set_research_modifiers([50, 75, 101, 100])
	
	_on_overview_pressed()





### RESEARCH ###

func set_current_research_progress(value : int):
	tabs[2].get_child(1).get_child(0).get_child(0).set_value(value)
	
func set_current_research_details(name : String, desc : String):
	tabs[2].get_child(1).get_child(0).get_child(1).set_text(name)
	tabs[2].get_child(1).get_child(1).set_text(desc)

func set_research_modifiers(values : Array[int]):
	for i in range(tabs[2].get_child(0).get_child(1).get_child_count()):
		
		var value_label = tabs[2].get_child(0).get_child(1).get_child(i).get_child(1)
		
		value_label.text = str(values[i]) + "%"
		
		if values[i] <= 50:
			value_label.set("theme_override_colors/font_color", Color(1,0.22, 0.22, 1)) #Wartości <= 50 są kolorowane na czerwono
		elif values[i] > 100:
			value_label.set("theme_override_colors/font_color", Color(0.24, 1, 0.24, 1)) #Wartości powyżej 100 są kolorowane na zielono
		else:
			value_label.set("theme_override_colors/font_color", Color(1, 1, 1, 1)) #W pozostałych przypadkach kolorowane są na biało





### STORAGE ###

## Wczytywanie ekwipunku
func load_equipment(base : Equipment, player : Equipment):
	base_equipment = base
	player_equipment = player
	
	update_storage_gui()

## Aktualizacja interfejsu przechowywanego ekwipunku
func update_storage_gui():
	update_item_list(tabs[1].get_child(0).get_child(0), base_equipment)
	update_item_list(tabs[1].get_child(1).get_child(1), player_equipment)
	
## Wyczyszczenie i aktualizacja jednej kategorii ekwipunku
func update_item_list(item_list : ItemList, equipment : Equipment):
	item_list.clear()
	
	for i in equipment.items:
		item_list.add_item(i.name, i.icon, false)

func transfer_item(index : int, to : Equipment, from : Equipment):
	var item = from.retrive_item(index)
	
	if item != null:
		if to.transfer_item(item):
			update_storage_gui()
		else:
			from.transfer_item(item)
	else:
		push_error("Couldn't retrive item")

func _on_base_eq_item_clicked(index, at_position, mouse_button_index):
	if last_click_container_flag and last_click_index == index and not double_click_timer.is_stopped():
		
		transfer_item(index, player_equipment, base_equipment)
		
	else:
		last_click_container_flag = true
		last_click_index = index
		double_click_timer.start(0)

func _on_player_eq_item_clicked(index, at_position, mouse_button_index):
	if not last_click_container_flag and last_click_index == index and not double_click_timer.is_stopped():
		
		transfer_item(index, base_equipment, player_equipment)
		
	else:
		last_click_container_flag = false
		last_click_index = index
		double_click_timer.start(0)




### OVERVIEW ###

## Wczytuje ilość produkowanych, przechowywanych i zużywanych surowców
func load_resource_info(production : Array[int], storage : Array[int], consumption : Array[int]):
	if production.size() != storage.size() or storage.size() != consumption.size():
		push_error("Niepoprawny rozmiar wczytywanych danych")
		return
		
	update_resource_label(tabs[0].get_child(0).get_child(1), production)
	update_resource_label(tabs[0].get_child(1).get_child(1), storage)
	update_resource_label(tabs[0].get_child(2).get_child(1), consumption)
	
	
## Funkcja pomocnicza zmieniająca wartości w jednej kategorii
func update_resource_label(resource_panel : HBoxContainer, values : Array[int]):
	
	for i in range(resource_panel.get_child_count()):
		var resource_indicator = resource_panel.get_child(i)
		resource_indicator.get_child(1).set_text(str(values[i]))

## Zmienia aktywną zakładkę na podany indeks
func switch_tab(index : int):
	if index < 0 or index >= tabs.size():
		push_error("Niewłaściwy indeks zakładki: " + str(index) + ". Maksymalny indeks: " + str(tabs.size()))
		return
	
	for i in range(tabs.size()):
		if i == index:
			tabs[i].visible = true;
		else:
			tabs[i].visible = false;
		

func _on_overview_pressed():
	switch_tab(0)
	

func _on_storage_pressed():
	switch_tab(1)
	

func _on_research_pressed():
	switch_tab(2)
	

func _on_communication_pressed():
	switch_tab(3)
	



