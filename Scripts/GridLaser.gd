extends GridActor
class_name GridLaser
# float for the time in between positions
var travel_time: float = 0.5
signal collision

func _process(delta: float) -> void:
	var nextPosition := position
	await get_tree().create_timer(0.5).timeout
	position.z -= 1
	if (not nextPosition.is_equal_approx(position)):
		#see if we can move to that spot
		var slots = g.getOccupants(nextPosition);
		#if it's allowed
		if (not slots is bool || slots != false):
			#check if that wasn't a blank space
			for slot in slots:
				collision.emit(slot);
			
			#actually move
			g.moveActor(self, nextPosition);
			# moved.emit(position)
			
			#kind of drag the visual a bit
			var tween = get_tree().create_tween()
			tween.tween_property(
				meshInstance, "global_position", g.getDrawPosition(position), 0.1
			).set_ease(Tween.EASE_OUT);
