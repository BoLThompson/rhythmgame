extends GridActor
class_name GridWall

func _ready() -> void:
  mesh = g.meshes["wall"];
  super();