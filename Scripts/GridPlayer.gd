extends GridActor
class_name GridPlayer

signal moved(Vector3)
signal collision(GridActor)
@export var health: int = 2
@onready var audio = $AudioStreamPlayer

func _ready() -> void:
	position = Vector3(floor(g.size.x/2), floor(g.size.y/2), g.size.z-1);
	super();

func beat() -> void:
	pass

func _process(delta: float) -> void:
	var nextPosition := position;
	if (Input.is_action_just_pressed("ui_left")):
		nextPosition.x -= 1;
	elif (Input.is_action_just_pressed("ui_right")):
		nextPosition.x += 1;
	
	if (Input.is_action_just_pressed("ui_up")):
		nextPosition.y += 1;
	elif (Input.is_action_just_pressed("ui_down")):
		nextPosition.y -= 1;
	
	
	#if we moved
	if (not nextPosition.is_equal_approx(position)):
		#see if we can move to that spot
		var slots = g.getOccupants(nextPosition);
		#if it's allowed
		if (not slots is bool || slots != false):
			#check if that wasn't a blank space
			for slot in slots:
				collision.emit(slot);
			
			#actually move
			g.moveActor(self,nextPosition);
			moved.emit(position)
			
			#kind of drag the visual a bit
			var tween = get_tree().create_tween()
			tween.tween_property(
				meshInstance, "global_position", g.getDrawPosition(position), 0.1
			).set_ease(Tween.EASE_OUT);

func collide(other: GridActor) -> void:
	#if anything that's not harmful gets added to the game we should handle it here
	collision.emit(other);
