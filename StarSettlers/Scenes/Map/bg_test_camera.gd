extends Camera2D

var scroll_speed: float = 50.0

func _process(delta):
	offset.y -= scroll_speed * delta
	set_offset(offset)
