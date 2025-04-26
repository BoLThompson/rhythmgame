extends Node
class_name GridActor

#reference to the GridManager
var g: GridManager;

signal collided

#my mesh
var mesh : Mesh;

var meshInstance : MeshInstance3D;

#grid coordinates
var position := Vector3();
var index: int = 0

func _ready() -> void:
	meshInstance = MeshInstance3D.new();
	meshInstance.mesh = mesh;
	add_child(meshInstance);
	meshInstance.global_position = g.getDrawPosition(position);

func adjustArrayIndex():
	g.actors[index] = null
	print(position.z)
	index = position.x + (g.size.x * (position.y)) + (g.size.x * g.size.y * (position.z - 1))
	g.actors[index] = self
	# print(position.z)
#when the downbeat happens
func beat() -> void:
	
	if (position.z >= g.size.z - 1): 
		queue_free();
		return;
	else:
		position.z += 1;
		adjustArrayIndex()
#put your visual somewhere
func _process(_delta: float) -> void:
	meshInstance.global_position = g.getDrawPosition(position);
