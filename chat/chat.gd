extends VBoxContainer

@export var message_scene: PackedScene
@export var max_messages: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	clear_chat()
	
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	
	Network.chat_object = self

func clear_chat():
	while $Scroll/Chat.get_child_count():
		$Scroll/Chat.remove_child($Scroll/Chat.get_child(0))

@rpc("call_local")
func send_global_message(id_from, message, server=false):
	add_message((str(Network.get_user_name(id_from)) if !server else "[Server]") + ": " + message)

@rpc
func send_private_message(id_from, id_to, message):
	add_message.rpc_id(id_to, Network.get_user_name(id_from) + " [PM]: " + message)
	add_message.rpc_id(id_from, Network.get_user_name(id_from) + " [PM -> " + Network.get_user_name(id_to) + "]: " + message)

func _on_send_pressed(_val=null) -> void:
	var message: String = $Input/TextEdit.text
	$Input/TextEdit.text = ""
	send_message.rpc_id(1, multiplayer.get_unique_id(), message)

@rpc("any_peer", "call_local")
func send_message(from_id, message):
	#if message.begins_with("/"):
	#	process_command(from_id, message)
	#else:
	send_global_message.rpc(from_id, message)

func process_command(from_id, message):
	var comps = message.split(" ")
	match comps[0]:
		"/help":
			pass
		"/dm":
			if comps.count() < 3:
				add_message("Error: Invalid syntax in command")
			var id = comps[1]
			if id.begins_with("\""):
				pass # Handle user names that have spaces in them
			if !id.is_valid_int():
				id = Network.get_user_name(id)
			send_private_message(from_id, id, ' '.join(comps.slice(2, -1)))
		"/global":
			send_global_message.rpc(from_id, message)
		"/team":
			pass
		"/quit":
			get_tree().quit()
		"/disconnect":
			get_tree().reload_current_scene()

func _on_player_connected(id):
	if id == 1:
		add_message("Connected to server")
	else:
		add_message("Player with id: " + str(id) + " has connected")

func _on_player_disconnected(id):
	if id == 1:
		add_message("Server has disconnected")
	else:
		add_message("Player with id: " + str(id) + " has disconnected")

@rpc("call_local")
func add_message(message):
	var message_label = message_scene.instantiate()
	message_label.text = message
	$Scroll/Chat.add_child(message_label)
	while $Scroll/Chat.get_child_count() > max_messages:
		$Scroll/Chat.remove_child($Scroll/Chat.get_child(0))

	$Scroll.scroll_vertical = $Scroll/Chat.size.y
