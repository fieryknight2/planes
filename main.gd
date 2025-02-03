extends Node

@export var max_clients : int
var peer = null
var players = {}

@export var default_game: PackedScene

func _ready():
	if Network.peer == null:
		get_tree().paused = true
		Network.disconnect_server()
	else:
		$UI/Control/Connect.visible = false
		

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
	get_tree().paused = false

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
	get_tree().paused = false
	
func start_game():
	$UI/Control/Connect.visible = false
	get_tree().paused = false
	
	if not multiplayer.is_server():
		return
	
	# change_level(default_game)

func change_level(scene: PackedScene):
	var level = $Game/SubViewportContainer/SubViewport/Game
	for lev in level.get_children():
		if lev.is_in_group("Level"):
			level.remove_child(lev)
			lev.queue_free()
	
	level.add_child(scene.instantiate())
