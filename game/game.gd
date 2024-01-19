extends Node2D

const ASTEROID_COUNT := 20
const ASTEROID_POSITION_RANGE := 2000.0
const ASTEROID_INITIAL_ANGULAR_VELOCITY := 1

@onready var asteroids: Node2D = $Asteroids

func _ready() -> void:
	if is_multiplayer_authority():
		for i in ASTEROID_COUNT:
			var a := preload("res://objects/asteroid.tscn").instantiate()
			a.position = Vector2(randf_range(-ASTEROID_POSITION_RANGE, ASTEROID_POSITION_RANGE), randf_range(-ASTEROID_POSITION_RANGE, ASTEROID_POSITION_RANGE))
			a.rotation_degrees = randf_range(0, 360)
			a.name = "Asteroid#" + str(i)
			a.angular_velocity = randf_range(-ASTEROID_INITIAL_ANGULAR_VELOCITY,ASTEROID_INITIAL_ANGULAR_VELOCITY)
			asteroids.add_child(a)
			
