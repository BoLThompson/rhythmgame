@tool
extends Node3D
class_name GridManager

@export var size := Vector3():
	set(val):
		size = val;
		create_grid();

@export var obstacleMap: Dictionary[String, PackedScene];

signal beat;

var player: GridPlayer;

@export var proxMaterial: Material;

var camZ: float;

class occupantList:
	var list: Array[GridActor] = [];

#array of lists of grid actors so that we can track who (and how many) are in what cell quickly
var occupants: Array[occupantList];

func _process(_delta:float) -> void:
	if not Engine.is_editor_hint():
		$Border.mesh.material.set_shader_parameter("charPos",player.meshInstance.global_position);
		proxMaterial.set_shader_parameter("charPos",player.meshInstance.global_position);

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.grid_manager = self
	occupants.resize(size.x*size.y*size.z);
	for i in range(occupants.size()):
		occupants[i] = occupantList.new();
	
	create_grid();
	
	for child in get_children():
		if child is GridPlayer: 
			player = child;
			GameManager.player = player
	
	camZ = $Camera.global_position.z;

	if not Engine.is_editor_hint():
		onPlayerMoved(player.position)
		player.moved.connect(onPlayerMoved)
		player.collision.connect(GameManager.on_player_collision
			#func(arg):
				#print("collision: ", arg);
				#pass
		)
		addActor(player);
		#print(occupants.map(func(o): return o.list));

func onPlayerMoved(loc: Vector3) ->void:
	var basePos = getDrawPosition(loc);
	basePos.y += 1;
	basePos.z = 0.0;
	var newCamPos = basePos + Vector3(0,0,camZ);
	var tween = get_tree().create_tween();
	tween.tween_property(
		$Camera, "global_position", newCamPos, 0.25
	).set_ease(Tween.EASE_IN_OUT);
	
	if (newCamPos.x != $Camera.global_position.x):
		tween = get_tree().create_tween();
		tween.tween_property(
			$Camera, "rotation", Vector3(0,0,0.025 * (-1 if newCamPos.x < $Camera.global_position.x else 1)), 0.125
		).set_ease(Tween.EASE_IN_OUT);
		tween.tween_property(
			$Camera, "rotation", Vector3(0,0,0.0), 0.125
		).set_ease(Tween.EASE_IN_OUT);

func spawnGridActor(type, position: Vector3) -> GridActor:
	var p: GridActor = type.instantiate();
	p.setMaterial(proxMaterial);
	p.position = position;
	p.g = self;
	beat.connect(p.beat)
	add_child(p);
	addActor(p);
	return p;

func create_grid():
	position.x = -(size.x/2.0);
	position.y = -(size.y/2.0);
	position.z = -size.z;
	
	for child in get_children():
		if child is MeshInstance3D and child != $Border:
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

#get the GridActor that occupies a given cell
func getOccupants(c: Vector3):
	if (c.x < 0 || c.x >= size.x || c.y < 0 || c.y >= size.y || c.z < 0 || c.z >= size.z):
		return false;
	return occupants[posToIndex(c)].list;
	return null;

#used to move an actor from one spot to another
func moveActor(actor: GridActor, newPos: Vector3) -> void:
	removeActor(actor);
	actor.position = newPos;
	addActor(actor);

#used to remove a reference to the actor in our occupants array
func removeActor(actor: GridActor) -> void:
	var space: occupantList = occupants[posToIndex(actor.position)];
	var indexInList = space.list.find(actor);
	# if (indexInList == -1):
	# 	print("BIG PROBLEM");
	# 	return
	space.list.remove_at(indexInList);

#used to put a reference to the actor in our occupants array
func addActor(actor: GridActor) -> void:
	var space: occupantList = occupants[posToIndex(actor.position)];
	space.list.append(actor);

func posToIndex(pos: Vector3) -> int:
	var index: int = int(pos.x) + int(size.x * pos.y) + int(size.x * size.y * pos.z);
	return index;


func step():
	beat.emit();
	
	var layer: Array = $CsvReader.readLayer();
	
	if (layer.size() != 0):
		for y in range(size.y):
			for x in range(size.x):
				if not layer[y][x] in obstacleMap: continue;
				
				spawnGridActor(obstacleMap[layer[y][x]], 
					Vector3(
						x,
						size.y-y-1,
						0
					)
				);
				
#func on_player_collision(other: GridActor):
	#player.health -= 1
	#if player.health < 0:
		#set_process(false)
		#player.queue_free()
		#await get_tree().create_timer(0.1).timeout
		#get_tree().reload_current_scene()
	#else:
		#player.audio.play()
