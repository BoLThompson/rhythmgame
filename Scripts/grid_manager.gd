@tool
extends Node3D
class_name GridManager

@export var size := Vector3():
	set(val):
		size = val;
		create_grid();

var meshes: Dictionary = {
	"wall": QuadMesh.new(),
	"asteroid": SphereMesh.new(),
};

signal beat;

var player: GridPlayer;

@export var proxMaterial: Material;

var actors: Array[GridActor]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	create_grid();
	actors.resize(size.x * size.y * size.z)
	if not Engine.is_editor_hint():
		player = spawnGridActor(GridPlayer, Vector3(floor(size.x/2), floor(size.y/2), size.z-1), BoxMesh.new());
		
		meshes["wall"].material = proxMaterial;
		player.moved.connect(onPlayerMoved)
		proxMaterial.set_shader_parameter("charPos",getDrawPosition(player.position));

func onPlayerMoved(loc: Vector3) ->void:
	player.adjustArrayIndex()
	# print(loc)
	#var occupant = getOccupant(loc)
	#if occupant:
		## print(occupant)
		#if occupant.position == player.position:
			#get_tree().reload_current_scene()
	proxMaterial.set_shader_parameter("charPos",getDrawPosition(loc));


func spawnGridActor(type, position: Vector3, mesh: Mesh = null) -> GridActor:
	
	var p: GridActor = type.new();
	p.position = position;
	if (mesh):
		p.mesh = mesh;
	p.g = self;
	beat.connect(p.beat)
	p.index = p.position.x + (size.x * (p.position.y)) + (size.x * size.y * p.position.z)
	actors[p.index] = p
	#for i in actors.size():
		#if actors[i] == null:
			#actors[i] = p
			#p.index = i
	add_child(p);
	return p;

func create_grid():
	position.x = -(size.x/2.0);
	position.y = -(size.y/2.0);
	position.z = -size.z;
	
	for child in get_children():
		if child is MeshInstance3D:
			child.free();
	var mesh1 := BoxMesh.new();
	mesh1.size = Vector3(0.2,0.02,0.02);
	mesh1.material = proxMaterial;
	var mesh2 := BoxMesh.new();
	mesh2.size = Vector3(0.02,0.2,0.02);
	mesh2.material = proxMaterial;
	var mesh3 := BoxMesh.new();
	mesh3.size = Vector3(0.02,0.02,0.2);
	mesh3.material = proxMaterial;
	for row in size.x+1:
		for col in size.y+1:
			for i in size.z+1:
				var marker := MeshInstance3D.new()
				marker.mesh = mesh1
				marker.position = Vector3(row, col, i)
				add_child(marker);
				marker = MeshInstance3D.new()
				marker.mesh = mesh2
				marker.position = Vector3(row, col, i)
				add_child(marker);
				marker = MeshInstance3D.new()
				marker.mesh = mesh3
				marker.position = Vector3(row, col, i)
				add_child(marker);


#get the center of a cell based on cell coords
func getDrawPosition(c: Vector3) -> Vector3:
	return global_position + c + Vector3(0.5,0.5,0.5);


func coordinatesToIndex(c: Vector3):
	var index = c.x + (size.x * c.y) + (size.x * size.y * c.z)
	#var z = int(index) / int(size.x * size.y)
	#print(z)
	if int(c.x) != int(index) % int(size.x):
		print("incorrect x value for index")
	if (int(c.y) != int((index/size.x)) % int(size.y)):
		print("incorrect y value for index")
	if (int(c.z) != int(index) / int(size.x * size.y)):
		print("incorrect z value for index")

#get the GridActor that occupies a given cell
func getOccupant(c: Vector3) -> GridActor:
	var index = c.x + (size.x * c.y) + (size.x * size.y * (c.z - 1))
	coordinatesToIndex(c)
	return actors[index]
	
func isPlayerColliding(actor: GridActor) -> bool:
	return player.position == actor.position
	
	
	#for i in actors.size():
		#if actors[i].position == c:
			#return actor;
	#return null;

var count: int = 0;

func step():
	beat.emit();
	# print("step")
	# if (count % 4 == 0):
	var coin_flip: int = randi_range(0, 1)
	if coin_flip == 0:
		spawnGridActor(GridWall, 
			Vector3(
				randi_range(0, size.x-1),
				randi_range(0,size.y-1),
				# size.x-1,size.y-1,
				0
			)
		);
	else:
		spawnGridActor(GridAsteroid, 
			Vector3(
				randi_range(0, size.x-1),
				randi_range(0,size.y-1),
				# size.x-1,size.y-1,
				0
			)
		);
	
	count = (count + 1) % 4;
	#spawn new grid actors according to the level reader
	pass;
