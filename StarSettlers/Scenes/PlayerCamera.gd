extends Camera2D

@export var min_zoom = 0.7
@export var max_zoom = 2.0
@export var zoom_speed = 0.04
var zoom_sensitivity = 10

@export var move_to_player_on_movement = false

var events = {}
var last_drag_distance = 0

func _ready():
	global_position = $"../Player".global_position

func _unhandled_input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			events[event.index] = event
		else:
			events.erase(event.index)
	if event is InputEventScreenDrag:
		events[event.index] = event
		if events.size() == 1:
			position += event.relative / zoom.x * -1
		elif events.size() == 2:
			var drag_distance = events[0].position.distance_to(events[1].position)
			if abs(drag_distance - last_drag_distance) > zoom_sensitivity:
				var new_zoom = (1 + zoom_speed) if drag_distance < last_drag_distance else (1 - zoom_speed)
				new_zoom = clamp(zoom.x * new_zoom, min_zoom, max_zoom)
				zoom = Vector2.ONE * new_zoom
				last_drag_distance = drag_distance
		# Do usuniecia po implementacji GUI
		elif events.size() == 3:
			global_position = $"../Player".global_position
	# Do usuniecia po implementacji GUI
	if event.is_action("ui_select"):
		global_position = $"../Player".global_position
	# Zoom na scrollu
	if event.is_action("scrollDown"):
		zoom = Vector2.ONE * clamp(zoom.x * (1 - zoom_speed), min_zoom, max_zoom)
	if event.is_action("scrollUp"):
		zoom = Vector2.ONE * clamp(zoom.x * (1 + zoom_speed), min_zoom, max_zoom)
		
