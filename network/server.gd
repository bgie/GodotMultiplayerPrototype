extends Node2D

@onready var chat: RichTextLabel = $CanvasLayer/ScrollContainer/Chat
@onready var players: Node2D = $Game/Players
@onready var background: Node = $Game/Background
@onready var camera_2d: Camera2D = $Camera2D

func _ready() -> void:
	background.queue_free() # Server should not show background. Because we say so.
	
	Network.message_received.connect(show_received_message_in_chat)
	for msg in Network.messages:
		show_received_message_in_chat(msg)
	
	Network.player_registered.connect(spawn_new_player)
	for peer_id in Network.usernames.keys():
		spawn_new_player(peer_id, Network.usernames[peer_id])

func show_received_message_in_chat(msg: ChatMessage) -> void:
	if msg.is_internal() or msg.is_from_server():
		print_chat("[color=#FF7F00]" + msg.message + "[/color]")
	else:
		print_chat("[color=#A0A0A0]" + msg.sender_name + "> " + msg.message + "[/color]")
	print(msg.message)

func print_chat(message: String) -> void:
	if chat.text.is_empty():
		chat.text = message
	else:
		chat.text += "\n" + message

func spawn_new_player(peer_id: int, username: String) -> void:
	var player_node := preload("res://player/player.tscn").instantiate()
	player_node.player_id = peer_id
	player_node.username = username
	player_node.position = Vector2(randf_range(-400, 400), randf_range(-200, 200))
	players.add_child(player_node)

func _process(_delta: float) -> void:
	var player_nodes := players.get_children()
	if not player_nodes.is_empty():
		var min_pos : Vector2 = player_nodes[0].position
		var max_pos := min_pos
		var average_pos := min_pos
		for i in range(1, len(player_nodes)):
			var pos : Vector2 = player_nodes[i].position
			if pos.x < min_pos.x:
				min_pos.x = pos.x
			if pos.y < min_pos.y:
				min_pos.y = pos.y
			if pos.x > max_pos.x:
				max_pos.x = pos.x
			if pos.y > max_pos.y:
				max_pos.y = pos.y
			average_pos += pos
		average_pos /= player_nodes.size()
		camera_2d.position = average_pos
		
		var fitting_zoom = (get_viewport_rect().size - Vector2(100,60)) / (max_pos - min_pos)
		var zoom_fact = min(min(0.5, fitting_zoom.x), fitting_zoom.y)
		camera_2d.zoom = Vector2(zoom_fact, zoom_fact)
