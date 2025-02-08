extends Node

var peer = null
var players = {
	1: "Server"
}

var chat_object

func _ready():
	get_tree().paused = true
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	
	if DisplayServer.get_name() == "headless":
		print("Automatically starting dedicated server.")
		print(OS.get_cmdline_user_args())
		if "--runas=web" in OS.get_cmdline_user_args():
			start_server.call_deferred(6381, 32, true)
		else:
			start_server.call_deferred(6381)
	else:
		print("Running as client/host")

func start_enet_server(port, max_clients=32):
	peer = ENetMultiplayerPeer.new()
	print("Starting ENet server")
	peer.create_server(port, max_clients)
	if peer.get_connection_status() == ENetMultiplayerPeer.CONNECTION_DISCONNECTED:
		return false
	multiplayer.multiplayer_peer = peer
	return true

func start_websocket_server(port):
	peer = WebSocketMultiplayerPeer.new()
	print("Creating web server")
	peer.create_server(port)
	if not peer.is_server_relay_supported:
		return false
	if peer.get_connection_status() == WebSocketMultiplayerPeer.CONNECTION_DISCONNECTED:
		return false
	multiplayer.multiplayer_peer = peer
	return true

func start_server(port, max_clients=32, force_web=false):
	if OS.get_name() == "Web" or force_web:
		return start_websocket_server(port)
	else:
		return start_enet_server(port, max_clients)

func connect_to_enet_server(address, port):
	peer = ENetMultiplayerPeer.new()
	print("Connecting to server at " + address + ":" + str(port))
	var error = peer.create_client(address, port)
	if error != OK:
		return false
	if peer.get_connection_status() == ENetMultiplayerPeer.CONNECTION_DISCONNECTED:
		return false
	multiplayer.multiplayer_peer = peer
	return true

func connect_to_websocket(address):
	peer = WebSocketMultiplayerPeer.new()
	print("Connecting to web server")
	peer.create_client(address)
	if peer.get_connection_status() == WebRTCMultiplayerPeer.CONNECTION_DISCONNECTED:
		return false
	multiplayer.multiplayer_peer = peer
	return true
	

func connect_to_server(address, port):
	if OS.get_name() == "Web":
		return connect_to_websocket("ws://" + address + ":" + str(port))
	else:
		return connect_to_enet_server(address, port)

func _on_player_connected(id):
	print("Player " + str(id) + " has connected")
	players[id] = id

func _on_player_disconnected(id):
	print("Player " + str(id) + " has disconnected")
	if players.has(id):
		players.erase(id)

func _on_connected_ok():
	print("Connected to server")

func _on_connected_fail():
	print("Error: Failed to connect to server")
	
func _on_server_disconnected():
	print("Error: Disconnected from server")

func disconnect_server():
	pass

@rpc("any_peer", "call_local")
func update_player_name(player_id, vname):
	if players.has(player_id):
		players[player_id] = vname
	
	update_player_names.rpc(players)

@rpc("any_peer")
func update_player_names(new_names):
	players = new_names

func get_user_name(id):
	id = str(id)
	if !id.is_valid_int():
		return id
		
	id = int(id)
	if id == 1:
		return "Server"
	if Network.players.has(id):
		return str(Network.players[id])
	else:
		return id
