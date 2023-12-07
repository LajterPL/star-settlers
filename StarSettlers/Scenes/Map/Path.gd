extends Node2D
@onready var player = $"../Player"

func _process(_delta):
	queue_redraw()

func _draw():
	if player.current_point_path.is_empty() or !get_meta("show"):
		return
	draw_polyline(player.current_point_path, get_meta("color"),get_meta("width"))
