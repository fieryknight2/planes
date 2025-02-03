extends Node

var peer = null
var players = {}

func _ready():
	get_tree().paused = true
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	
	if DisplayServer.get_name() == "headless":
		print("Automatically starting dedicated server.")
		start_server.call_deferred(6381)

func start_server(port, max_clients=32):
	peer = ENetMultiplayerPeer.new()
	peer.create_server(port, max_clients)
	if peer.get_connection_status() == ENetMultiplayerPeer.CONNECTION_DISCONNECTED:
		return false
	multiplayer.multiplayer_peer = peer
	return true

func connect_to_server(address, port):
	peer = ENetMultiplayerPeer.new()
	print("Connecting to server at " + address + ":" + str(port))
	var error = peer.create_client(address, port)
	if error != OK:
		return false
	if peer.get_connection_status() == ENetMultiplayerPeer.CONNECTION_DISCONNECTED:
		return false
	print("Connected to server")
	multiplayer.multiplayer_peer = peer
	return true

func _on_player_connected(id):
	pass # print("Player " + str(id) + " has connected")

func _on_player_disconnected(id):
	pass # print("Player " + str(id) + " has disconnected")

func _on_connected_ok():
	pass

func _on_connected_fail():
	pass
	
func _on_server_disconnected():
	pass

func start_game():
	pass

func disconnect_server():
	pass
