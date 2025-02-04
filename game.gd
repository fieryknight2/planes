extends Node2D

@export var vignette: Node
@export var plane: PackedScene

@export var crate_time: float
@export var crate: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().current_scene.set_vignette(self)
	$Background.get_child(0).vignette = vignette
	
	if not multiplayer.is_server():
		return
	
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)
	
	for id in multiplayer.get_peers():
		add_player(id)
	
	if not OS.has_feature("dedicated_server"):
		add_player(1)
	
	new_crate()

func new_crate():
	get_tree().create_timer(crate_time).connect("timeout", new_crate)
	
	var ncrate = crate.instantiate()
	ncrate.position.x = randi_range(-1800, 1800)
	ncrate.position.y = -1200
	ncrate.m_type = "health"
	$Crates.add_child(ncrate, true)

func add_player(id):
	print("Player " + str(id) + " has connected")
	var nplayer = plane.instantiate()
	nplayer.player = id
	nplayer.name = str(id)
	nplayer.bullet_node = $Bullets.get_path()
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
