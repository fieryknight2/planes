extends Node2D

@export var vignette: Node
@export var plane: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Background.vignette = vignette
	
	if not multiplayer.is_server():
		return
		
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)
	
	if not OS.has_feature("dedicated_server"):
		add_player(1)
	
	for id in multiplayer.get_peers():
		add_player(id)

func add_player(id):
	print("Player " + str(id) + " has connected")
	var nplayer = plane.instantiate()
	nplayer.player = id
	nplayer.name = str(id)
	$Players.add_child(nplayer, true)

func remove_player(id):
	print("Player " + str(id) + " has disconnected")
	if not $Players.has_node(str(id)):
		return
	$Players.get_node(str(id)).queue_free()

func _exit_tree():
	if not multiplayer.is_server():
		return
		
	multiplayer.peer_connected.disconnect(add_player)
	multiplayer.peer_disconnected.disconnect(remove_player)
