extends Control

@onready var main_panel: VBoxContainer = $MainPanel
@onready var connect_panel: VBoxContainer = $ConnectPanel
@onready var host_label: Label = $ConnectPanel/HostLabel
@onready var join_label: Label = $ConnectPanel/JoinLabel
@onready var url: LineEdit = $ConnectPanel/Settings/Url
@onready var port: LineEdit = $ConnectPanel/Settings/Port
@onready var username_label: Label = $ConnectPanel/Settings/UsernameLabel
@onready var username: LineEdit = $ConnectPanel/Settings/Username

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
	username.text = usernames[randi_range(0, len(usernames))]

func show_main() -> void:
	main_panel.visible = true
	connect_panel.visible = false

func show_connect() -> void:
	main_panel.visible = false
	connect_panel.visible = true
	host_label.visible = (mode == ConnectionMode.SERVER)
	join_label.visible = (mode == ConnectionMode.CLIENT)
	username_label.visible = (mode == ConnectionMode.CLIENT)
	username.visible = (mode == ConnectionMode.CLIENT)

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

func update_globals() -> void:
	Network.url = url.text.strip_edges()
	Network.port = port.text.to_int()
	Network.username = username.text.strip_edges()

func _on_connect_button_pressed() -> void:
	update_globals()
	if mode == ConnectionMode.SERVER:
		if Network.start_server():
			get_tree().change_scene_to_packed(preload("res://network/server.tscn"))
	else:
		if Network.start_client():
			get_tree().change_scene_to_packed(preload("res://network/client.tscn"))

func _on_auto_connect_timer_timeout() -> void:
	if OS.is_debug_build():
		update_globals()
		if Network.start_server():
			get_window().position = Vector2i(0,0)
			get_tree().change_scene_to_packed(preload("res://network/server.tscn"))
		elif Network.start_client():
			get_tree().change_scene_to_packed(preload("res://network/client.tscn"))
