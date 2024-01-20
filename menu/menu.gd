extends Control

@onready var _main_panel: VBoxContainer = $MainPanel
@onready var _connect_panel: VBoxContainer = $ConnectPanel
@onready var _host_label: Label = $ConnectPanel/HostLabel
@onready var _join_label: Label = $ConnectPanel/JoinLabel
@onready var _url: LineEdit = $ConnectPanel/Settings/Url
@onready var _port: LineEdit = $ConnectPanel/Settings/Port
@onready var _username_label: Label = $ConnectPanel/Settings/UsernameLabel
@onready var _username: LineEdit = $ConnectPanel/Settings/Username

enum ConnectionMode {
	SERVER, CLIENT
}
var mode := ConnectionMode.SERVER

func _ready() -> void:
	set_random_username()
	show_main()

func set_random_username() -> void:
	var file = FileAccess.open("res://menu/random_names.txt", FileAccess.READ)
	var usernames = file.get_as_text().split("\n", false)
	_username.text = usernames[randi_range(0, len(usernames))]

func show_main() -> void:
	_main_panel.visible = true
	_connect_panel.visible = false

func show_connect() -> void:
	_main_panel.visible = false
	_connect_panel.visible = true
	_host_label.visible = (mode == ConnectionMode.SERVER)
	_join_label.visible = (mode == ConnectionMode.CLIENT)
	_username_label.visible = (mode == ConnectionMode.CLIENT)
	_username.visible = (mode == ConnectionMode.CLIENT)

func _on_exit_button_pressed() -> void:
	get_tree().quit()

func _on_host_button_pressed() -> void:
	mode = ConnectionMode.SERVER
	show_connect()

func _on_join_button_pressed() -> void:
	mode = ConnectionMode.CLIENT
	show_connect()

func _on_back_button_pressed() -> void:
	show_main()

func _on_connect_button_pressed() -> void:
	if mode == ConnectionMode.SERVER:
		if Network.start_server(_url.text.strip_edges(), _port.text.to_int()):
			get_tree().change_scene_to_packed(preload("res://network/server.tscn"))
	else:
		if Network.start_client(_url.text.strip_edges(), _port.text.to_int(), _username.text.strip_edges()):
			get_tree().change_scene_to_packed(preload("res://network/client.tscn"))

func _on_auto_connect_timer_timeout() -> void:
	if OS.is_debug_build():
		if Network.start_server(_url.text.strip_edges(), _port.text.to_int()):
			get_window().position = Vector2i(0,0)
			get_tree().change_scene_to_packed(preload("res://network/server.tscn"))
		elif Network.start_client(_url.text.strip_edges(), _port.text.to_int(), _username.text.strip_edges()):
			get_tree().change_scene_to_packed(preload("res://network/client.tscn"))
