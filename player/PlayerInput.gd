extends MultiplayerSynchronizer

@export var velocity: Vector2

func _ready():
	# Only process for the local player.
	set_physics_process(is_multiplayer_authority())

func _physics_process(_delta: float) -> void:
	velocity = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
