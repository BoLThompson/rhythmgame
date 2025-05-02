extends GridActor
class_name GridLaser



# float for the time in between positions
var travel_time: float = 0.5
@onready var move_timer = $moveTimer
signal collision

func _ready() -> void:
	move_timer.start()
	super();

func beat() -> void:
	pass
	
	
func new_position():
	var newPos := position;
	newPos.z -= 1;
	tryMoving(newPos);	
	moveVisual();
	
	
	



func _on_move_timer_timeout() -> void:
	new_position()
