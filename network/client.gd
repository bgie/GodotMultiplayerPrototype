extends Node2D

@onready var chat: RichTextLabel = $CanvasLayer/VBoxContainer/Chat
@onready var chat_input: LineEdit = $CanvasLayer/VBoxContainer/HBoxContainer/ChatInput
@onready var send_chat_button: Button = $CanvasLayer/VBoxContainer/HBoxContainer/SendChatButton

func _ready() -> void:
	Network.message_received.connect(show_received_message_in_chat)
	for msg in Network.messages:
		show_received_message_in_chat(msg)

func show_received_message_in_chat(msg: ChatMessage) -> void:
	if msg.is_internal() or msg.is_from_server():
		print_chat("[color=#FF7F00]" + msg.message + "[/color]")
	elif msg.is_from_myself(multiplayer.get_unique_id()):
		print_chat("[color=#7F7F7F]" + msg.sender_name + "> " + msg.message + "[/color]")
	else:
		print_chat("[color=#EFEFEF]" + msg.sender_name + "> " + msg.message + "[/color]")
	print(msg.message)

func print_chat(message: String) -> void:
	if chat.text.is_empty():
		chat.text = message
	else:
		chat.text += "\n" + message

func _on_send_chat_button_pressed() -> void:
	var message := chat_input.text.strip_edges()
	if message.length() > 0:
		Network.send_message_to_server(message)
	chat_input.clear()

func _on_chat_input_text_submitted(_new_text: String) -> void:
	_on_send_chat_button_pressed()
