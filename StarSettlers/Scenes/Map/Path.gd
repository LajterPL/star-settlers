extends Node2D
@onready var player = $"../Player"

func _process(_delta):
	pass
	#queue_redraw()

func _draw():
	if player.current_point_path.is_empty():
		return
	draw_polyline(player.current_point_path, Color.RED,2)
