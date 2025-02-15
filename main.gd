extends Node

@export var max_clients : int
var peer = null
var players = {}

var player_name = ""
var player_color = ""

@export var default_game: PackedScene
@export var default_level: PackedScene

func _ready():
	randomize()
	
	if Network.peer == null:
		get_tree().paused = true
		Network.disconnect_server()
	else:
		$UI/Control/Connect.visible = false
	
	if OS.get_name() == "Web":
		# Don't allow web player to start a server
		%StartServer.visible = false
	
	if DisplayServer.get_name() == "headless":
		start_game()
	
	%PlayerColor.color = Color.from_hsv(randf(), 1.0, 1.0)
	$UI/Control/Chat.visible = false

func _on_connect_pressed() -> void:
	%ConnectError.visible = false
	
	# Get the port number, it must be an integer between 0 and 65536
	if not (%Port.text.is_valid_int()):
		%ConnectError.text = "Invalid port"
		%ConnectError.visible = true
	var port = int(%Port.text)
	if not (port > 0 and port <= 65535):
		%ConnectError.text = "Invalid port number"
		%ConnectError.visible = true
	
	# Get connection IP address, default to host machine
	var address = %IP.text
	if address.is_empty():
		address = "127.0.0.1"
		
	var error = Network.connect_to_server(address, port)
	if not error:
		%ConnectError.text = "Error connecting to server"
		%ConnectError.visible = true
		return
	
	$UI/Control/Connect.visible = false
	$UI/Control/Play.visible = true
	%PlayerName.grab_focus()
	
	start_game()

func _on_start_server_pressed() -> void:
	%ConnectError.visible = false
	
	# Validate the port number
	if not (%Port.text.is_valid_int() and int(%Port.text) > 0 and int(%Port.text) <= 65535):
		%ConnectError.text = "Invalid port number"
		%ConnectError.visible = true
	
	# Start a network server on specificed port
	var error = Network.start_server(int(%Port.text))
	if not error:
		%ConnectError.text = "Error starting server"
		%ConnectError.visible = true
		return
	
	$UI/Control/Connect.visible = false
	
	if DisplayServer.get_name() != "headless":
		$UI/Control/Play.visible = true
		%PlayerName.grab_focus()
	
	start_game()

func set_vignette(node):
	node.vignette = $Effects/Control/Color

func start_game():
	$UI/Control/Connect.visible = false
	$UI/Control/Chat.visible = true
	
	get_tree().paused = false
	
	if $Game/SubViewportContainer/SubViewport.has_node("Background"):
		$Game/SubViewportContainer/SubViewport/Background.queue_free()
	
	if not multiplayer.is_server():
		return
	
	for child in $Game/SubViewportContainer/SubViewport.get_children():
		$Game/SubViewportContainer/SubViewport.remove_child(child)
	
	var game = default_game.instantiate()
	$Game/SubViewportContainer/SubViewport.add_child(game, true)
	
	# change_level(default_level)

func change_level(scene: PackedScene):
	var level = $Game/SubViewportContainer/SubViewport.get_child(0)
	for lev in level.get_children():
		if lev.is_in_group("Level"):
			level.remove_child(lev)
			lev.queue_free()
	
	level.add_child(scene.instantiate())


func _on_play_pressed(_val=null) -> void:
	$UI/Control/Play.visible = false
	if not %PlayerName.text:
		%PlayerName.text = "<unnamed>"
	Network.update_player_name.rpc_id(1, multiplayer.get_unique_id(), %PlayerName.text)
	
	$Game/SubViewportContainer/SubViewport.get_child(0).add_local_player.rpc_id(1, multiplayer.get_unique_id(), %PlayerName.text, %PlayerColor.color)

func kill_player(id, death_message):
	display_play.rpc_id(int(id))
	
	Network.chat_object.send_global_message(1, death_message, true)
	remove_player(id)

func remove_player(id):
	$Game/SubViewportContainer/SubViewport.get_child(0).remove_player(id)

@rpc("call_local")
func display_play():
	$UI/Control/Play.visible = true
	%PlayerName.grab_focus()
