extends GridActor
class_name GridPacer

enum movedir {
	UP,
	DOWN,
	LEFT,
	RIGHT,
	NONE,
}

@export var direction = movedir.NONE:
	set(newDir):
		direction = newDir;
		updateRotation(true);

static var directionToDegrees: Dictionary = {
	movedir.UP: 0,
	movedir.DOWN: 180,
	movedir.LEFT: 90,
	movedir.RIGHT: 270,
};

static var directionToMotion: Dictionary = {
	movedir.UP: Vector3(0,1,0),
	movedir.DOWN: Vector3(0,-1,0),
	movedir.LEFT: Vector3(-1,0,0),
	movedir.RIGHT: Vector3(1,0,0),
};

static var directionToFlip: Dictionary = {
	movedir.UP: movedir.DOWN,
	movedir.LEFT: movedir.RIGHT,
	movedir.RIGHT: movedir.LEFT,
	movedir.DOWN: movedir.UP,
};

func _ready() -> void:
	assert(direction != movedir.NONE);
	super();

func beat() -> void:
	#try moving forward, see if we're about to die
	var newPos: Vector3 = Vector3(position);
	newPos.z += 1;
	
	var forwardSlots = g.getOccupants(newPos);

	#if we can't move then this is the end of the tunnel, so just be dead
	if (forwardSlots is bool && forwardSlots == false):
		queue_free();
		return;

	#we don't actually care about collisions though cause we're not moving there
	
	#try moving in our direction
	newPos = newPos + Vector3(directionToMotion[direction]);
	
	var sideSlots = g.getOccupants(newPos);
	
	#if we can't move that way, spend this turn flipping around
	if (sideSlots is bool && sideSlots == false):
		direction = directionToFlip[direction];
		
		#we already know it's safe to move forward, so do
		g.moveActor(self, Vector3(position)+Vector3(0,0,1));
		moveVisual();
		for slot in forwardSlots:
			if slot.has_method("collide"):
				slot.collide(self);
		return;
	
	#okay, this is the diagonal move
	for slot in sideSlots:
		if slot.has_method("collide"):
			slot.collide(self);
	
	#actually move
	g.moveActor(self, newPos);
	
	moveVisual();	

func updateRotation(instant: bool = false) -> void:
	if (instant):
		$Visual.rotation_degrees = Vector3(0,0,directionToDegrees[direction]);
	else:
		var tween = get_tree().create_tween();
		tween.tween_property($Visual, "rotation_degrees", 
			Vector3(0,0,directionToDegrees[direction]),
			0.25
		);
