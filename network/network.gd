extends Node

var usernames = {}
signal player_registered(peer_id: int, username: String)

var messages : Array[ChatMessage] = []
signal message_received(message: ChatMessage)

var _multiplayer_peer := ENetMultiplayerPeer.new()
var _username : String
var _connected_peer_ids := PackedInt32Array()

func _enter_tree() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func start_server(url: String, port: int) -> bool:
	_multiplayer_peer.set_bind_ip(url)
	if _multiplayer_peer.create_server(port) == OK:
		multiplayer.multiplayer_peer = _multiplayer_peer
		internal_message("Started server.")
		return true
	return false

func start_client(url: String, port: int, username: String) -> bool:
	_username = username
	_multiplayer_peer.set_target_peer(MultiplayerPeer.TARGET_PEER_SERVER)
	if _multiplayer_peer.create_client(url, port) == OK:
		multiplayer.multiplayer_peer = _multiplayer_peer
		internal_message("Started client.")
		return true
	return false

func internal_message(message: String) -> void:
	var msg := ChatMessage.new()
	msg.message = message
	messages.append(msg)
	message_received.emit(msg)

func notify_client(peer_id: int, message: String) -> void:
	if multiplayer.is_server():
		rpc_id(peer_id, "_message_for_client", MultiplayerPeer.TARGET_PEER_SERVER, "", message)

func notify_other_clients(origin_peer_id: int, message: String) -> void:
	if multiplayer.is_server():
		for client_id in _connected_peer_ids:
			if client_id != origin_peer_id:
				notify_client(client_id, message)

func send_message_to_server(message: String) -> void:
	rpc("_message_for_server", message)

func _on_peer_connected(new_peer_id : int) -> void:
	if multiplayer.is_server():
		_connected_peer_ids.append(new_peer_id)
		internal_message("Player " + str(new_peer_id) + " connected.")
		internal_message("Currently connected players: " + str(_connected_peer_ids))
		if OS.is_debug_build():
			rpc_id(new_peer_id, "_set_debug_window_position", len(_connected_peer_ids)-1)

func _on_peer_disconnected(leaving_peer_id : int) -> void:
	if multiplayer.is_server():
		var idx := _connected_peer_ids.find(leaving_peer_id)
		if idx >= 0:
			_connected_peer_ids.remove_at(idx)
		var peer_username : String = usernames[leaving_peer_id]
		usernames.erase(leaving_peer_id)
		notify_other_clients(leaving_peer_id, "Player " + peer_username + " (" + str(leaving_peer_id) + ") left.")
		internal_message("Player " + str(leaving_peer_id) + " disconnected.")
		internal_message("Currently connected players: " + str(_connected_peer_ids))

func _on_connected_to_server() -> void:
	internal_message("Connected to server.")
	rpc("_register_username", _username)

func _on_server_disconnected() -> void:
	_multiplayer_peer.close()
	internal_message("Connection to server lost.")

@rpc("any_peer", "reliable")
func _set_debug_window_position(window_index: int) -> void:
	get_window().position = Vector2i(window_index * 960, 540)

@rpc("any_peer", "reliable")
func _message_for_server(message: String) -> void:
	if multiplayer.is_server():
		var sender_id = multiplayer.get_remote_sender_id()
		var sender_name = usernames[multiplayer.get_remote_sender_id()]
		for client_id in _connected_peer_ids:
			rpc_id(client_id, "_message_for_client", sender_id, sender_name, message)
		_message_for_client(sender_id, sender_name, message)

@rpc("reliable")
func _message_for_client(sender_peer_id: int, sender_name: String, message: String) -> void:
	var msg := ChatMessage.new()
	msg.sender_peer_id = sender_peer_id
	msg.sender_name = sender_name
	msg.message = message
	messages.append(msg)
	message_received.emit(msg)

@rpc("any_peer", "reliable")
func _register_username(peer_username: String) -> void:
	if multiplayer.is_server():
		var new_peer_id := multiplayer.get_remote_sender_id()
		var other_player_names = usernames.values()
		usernames[new_peer_id] = peer_username
		internal_message("Player " + str(new_peer_id) + " joined using name " + peer_username)
		if other_player_names.is_empty():
			notify_client(new_peer_id, "Joined game. You are all alone.")
		else:
			notify_client(new_peer_id, "Joined game. Playing with " + ", ".join(other_player_names) + ".")
		notify_other_clients(new_peer_id, "Player " + peer_username + " joined.")
		
		player_registered.emit(new_peer_id, peer_username)

