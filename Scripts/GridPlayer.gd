extends GridActor
class_name GridPlayer

signal moved(Vector3)

	
func beat() -> void:
	pass
	

func _process(delta: float) -> void:
	var moved_now := false
	#print(position)
	if (Input.is_action_just_pressed("ui_left")):
		if (position.x > 0):
			position.x -= 1;
			moved_now = true;
	elif (Input.is_action_just_pressed("ui_right")):
		if (position.x < g.size.x - 1):
			position.x += 1;
			moved_now = true;
	
	if (Input.is_action_just_pressed("ui_up")):
		if (position.y < g.size.y - 1):
			position.y += 1;
			moved_now = true;
	elif (Input.is_action_just_pressed("ui_down")):
		if (position.y > 0):
			position.y -= 1;
			moved_now = true;
	
	if (moved_now): moved.emit(position)
	
	super(delta);
