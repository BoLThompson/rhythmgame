extends Node
class_name GridActor

#reference to the GridManager
@onready var g: GridManager = get_parent();

var meshInstance : Node3D;

#grid coordinates
var position := Vector3();

func _ready() -> void:
	meshInstance = $Visual
	meshInstance.global_position = g.getDrawPosition(position);

#when the downbeat happens
func beat() -> void:
	var newPos := position;
	newPos.z += 1;
	tryMoving(newPos);	
	moveVisual();

func tryMoving(newPos: Vector3) -> void:
	var slots = g.getOccupants(newPos);

	#if we can't move then this is the end of the tunnel, so just be dead
	if (slots is bool && slots == false):
		queue_free();
		return;

	for slot in slots:
		if slot.has_method("collide"):
			slot.collide(self);

	#actually move
	g.moveActor(self, newPos);

func moveVisual() -> void:
	#drag your visual along
	var tween = get_tree().create_tween()
	tween.tween_property(
		meshInstance, "global_position", g.getDrawPosition(position), 0.2
	).set_ease(Tween.EASE_OUT);

func setMaterial(material) -> void:
	for child in $Visual.get_children():
		child.set_surface_override_material(0,material);

func _exit_tree() -> void:
	g.removeActor(self);
