extends CanvasLayer

signal building_chosen(option)

func _on_back_pressed():
	queue_free()
	
func _on_button_pressed(option):
	emit_signal("building_chosen", option)
	queue_free()
