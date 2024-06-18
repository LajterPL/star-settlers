extends HBoxContainer

@onready var oxygen = $Oxygen
@onready var water = $Water
@onready var electr = $Electricity
@onready var steel = $Steel

var oxygen_gain = 5
var water_gain = 5
var electr_gain = 5
var steel_gain = 5

func _on_oxygen_timer_timeout():
	var curr = int(oxygen.text)
	curr += oxygen_gain
	oxygen.text = str(curr)
	
func _on_water_timer_timeout():
	var curr = int(water.text)
	curr += water_gain
	water.text = str(curr)

func _on_electricity_timer_timeout():
	var curr = int(electr.text)
	curr += electr_gain
	electr.text = str(curr)

func _on_steel_timer_timeout():
	var curr = int(steel.text)
	curr += steel_gain
	steel.text = str(curr)
