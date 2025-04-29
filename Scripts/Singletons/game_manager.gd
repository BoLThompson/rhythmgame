extends Node

var grid_manager: GridManager
var player: GridPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func on_player_collision(other: GridActor):
	player.health -= 1
	if player.health < 0:
		grid_manager.set_process(false)
		
		player.queue_free()
		await get_tree().create_timer(0.1).timeout
		get_tree().reload_current_scene()
	else:
		player.audio.play()
