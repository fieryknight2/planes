extends Node2D

@export var vignette: Node
@export var plane: PackedScene

@export var crate_time: float
@export var crate_types: Array[String]
@export var crate: PackedScene

@export var background: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().current_scene.set_vignette(self)
	
	if not multiplayer.is_server():
		return
	
	$Background.add_child(background.instantiate())
	
	# multiplayer.peer_connected.connect(add_player)
	# multiplayer.peer_disconnected.connect(remove_player)
	
	# for id in multiplayer.get_peers():
	# 	add_player(id)
	
	# if not OS.has_feature("dedicated_server") and not DisplayServer.get_name() == "headless":
	# 	add_player(1)
	
	new_crate()

func _process(_delta):
	$Background.get_child(0).vignette = vignette

func new_crate():
	get_tree().create_timer(crate_time).connect("timeout", new_crate)
	
	var ncrate = crate.instantiate()
	ncrate.position.x = randi_range(-1800, 1800)
	ncrate.position.y = -1200
	ncrate.m_type = crate_types.pick_random()
	$Crates.add_child(ncrate, true)

func add_player(id, vname, color):
	var nplayer = plane.instantiate()
	nplayer.player = id
	nplayer.name = str(id)
	nplayer.visual_name = vname
	Network.players[id] = vname
	nplayer.bullet_node = $Bullets.get_path()
	nplayer.color = color
	$Players.add_child(nplayer, true)

func remove_player(id):
	if not $Players.has_node(str(id)):
		return
	$Players.get_node(str(id)).queue_free()

func _exit_tree():
	if not multiplayer.is_server():
		return
		
	multiplayer.peer_connected.disconnect(add_player)
	multiplayer.peer_disconnected.disconnect(remove_player)

@rpc("any_peer", "call_local")
func add_local_player(id, vname, color):
	add_player(id, vname, color)
