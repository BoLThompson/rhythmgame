extends Node
@export var size: Vector2 = Vector2(10,10);
@export var debugMode: bool = false;

@export_file ("*.csv") var levelFile:String = ""

var level: Array;
var nextIndex: int = 0;

func _ready() -> void:
	load_csv();

func load_csv() -> void:
	level = [];
	var file = FileAccess.open(levelFile, FileAccess.READ)
	
	while !file.eof_reached():
		var grid = [];
		for y:int in range(0,size.y):
			var line = file.get_csv_line();
			if (line[0] == "s"):
				line = [];
				while (line.size() < size.x):
					line.append("");
				while (grid.size() < size.y):
					grid.append(line);
				break;
		
			while (line.size() < size.x):
				line.append("");
			grid.append(line);
		level.append(grid);
	file.close()
	nextIndex = 0;

func readLayer() -> Array:
	if (nextIndex >= level.size()): return []
	nextIndex+=1;
	return level[nextIndex-1];
