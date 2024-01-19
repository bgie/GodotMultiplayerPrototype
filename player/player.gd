extends CharacterBody2D

const PUSH_FORCE := 400.0

@export var player_id : int = 0:
	set(id):
		player_id = id
		self.name = str(id)
		$PlayerInput.set_multiplayer_authority(id)
@export var username: String

@export var sync_position : Vector2
@export var sync_rotation : float

@onready var character: Node2D = $Character
@onready var camera: Camera2D = $Camera2D
@onready var name_label: Label = $NameLabel
@onready var player_input: MultiplayerSynchronizer = $PlayerInput

func _ready() -> void:
	if player_input.is_multiplayer_authority():
		name_label.visible = false
		camera.enabled = true
	else:
		name_label.text = username

func _physics_process(_delta: float) -> void:
	if is_multiplayer_authority():
		velocity = player_input.velocity * character.speed
		if move_and_slide():
			for i in get_slide_collision_count():
				var col = get_slide_collision(i)
				if col.get_collider() is RigidBody2D:
					var target = col.get_collider() as RigidBody2D
					target.apply_force(col.get_normal() * -PUSH_FORCE, col.get_position() - target.global_position)
		sync_position = position
		sync_rotation = rotation
	else:
		position = sync_position
		rotation = sync_rotation
