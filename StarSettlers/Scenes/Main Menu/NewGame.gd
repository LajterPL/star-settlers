extends CanvasLayer



func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/Main Menu/MainMenu.tscn")


func _on_confirm_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/Map/test_map.tscn")
