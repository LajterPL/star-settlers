extends CanvasLayer

@onready var left_item_list : ItemList = $LeftItemList
@onready var right_item_list : ItemList = $RightItemList

# Timer określający maksymalny odstęp czasowy między kliknięciami 
@onready var double_click_timer : Timer = $DoubleClickTimer

var last_click_container_flag : bool = false # Flaga określająca która lista została ostatnio kliknięta
var last_click_index : int = 0 # Indeks ostatniego klikniętego przedmiotu

var left_equipment : Equipment
var right_equipment : Equipment

func _ready():
	var eq1 = Equipment.new(4)
	var eq2 = Equipment.new(4)
	
	eq1.transfer_item(Item.new(&"Patyk", "", load("res://icon.svg")))
	eq1.transfer_item(Item.new(&"Kamień", "", load("res://icon.svg")))
	eq1.transfer_item(Item.new(&"Karabin laserowy", "", load("res://icon.svg")))
	eq2.transfer_item(Item.new(&"Apteczka", "", load("res://icon.svg")))
	eq2.transfer_item(Item.new(&"Racja żywnościowa", "", load("res://icon.svg")))
	
	load_equipment(eq1, eq2)

func _on_right_item_list_item_clicked(index, at_position, mouse_button_index):
	if not last_click_container_flag and last_click_index == index and not double_click_timer.is_stopped():
		
		transfer_item(index, left_equipment, right_equipment)
		
	else:
		last_click_container_flag = false
		last_click_index = index
		double_click_timer.start(0)


func _on_left_item_list_item_clicked(index, at_position, mouse_button_index):
	if last_click_container_flag and last_click_index == index and not double_click_timer.is_stopped():
		
		transfer_item(index, right_equipment, left_equipment)
		
	else:
		last_click_container_flag = true
		last_click_index = index
		double_click_timer.start(0)

func transfer_item(index : int, to : Equipment, from : Equipment):
	var item = from.retrive_item(index)
	
	if item != null:
		if to.transfer_item(item):
			update_gui()
		else:
			from.transfer_item(item)
	else:
		push_error("Couldn't retrive item")

func load_equipment(left : Equipment, right : Equipment):
	left_equipment = left
	right_equipment = right
	
	update_gui()
	
func update_gui():
	update_item_list(left_item_list, left_equipment)
	update_item_list(right_item_list, right_equipment)

func update_item_list(item_list : ItemList, equipment : Equipment):
	item_list.clear()
	
	for i in equipment.items:
		item_list.add_item(i.name, i.icon, false)
