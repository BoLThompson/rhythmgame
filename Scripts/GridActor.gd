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
	position.z += 1;
	if (position.z >= g.size.z): queue_free();
	
	var tween = get_tree().create_tween()
	tween.tween_property(
		meshInstance, "global_position", g.getDrawPosition(position), 0.2
	).set_ease(Tween.EASE_OUT);
	#tween.tween_property(
		#text, "scale", Vector2.ZERO, 0.25
	#).set_ease(Tween.EASE_IN).set_delay(0.5);

func setMaterial(material) -> void:
	for child in $Visual.get_children():
		child.set_surface_override_material(0,material);

##put your visual somewhere
#func _process(_delta: float) -> void:
	#meshInstance.global_position = g.getDrawPosition(position);
