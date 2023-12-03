extends Camera2D

# The speed at which the camera moves up
var scroll_speed: float = 50.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Move the camera upwards
	offset.y -= scroll_speed * delta
	set_offset(offset)
