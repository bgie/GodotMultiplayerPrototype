extends RigidBody2D

@export var sync_position : Vector2
@export var sync_rotation : float
@export var sync_linear_velocity : Vector2
@export var sync_angular_velocity : float

func _integrate_forces(_state : PhysicsDirectBodyState2D) -> void:
	# Synchronizing the physics values directly causes problems since you can't
	# directly update physics values outside of _integrate_forces. This is
	# an attempt to resolve that problem while still being able to use
	# MultiplayerSynchronizer to replicate the values.

	# The object owner makes shadow copies of the physics values.
	# These shadow copies get synchronized by the MultiplyaerSynchronizer
	# The client copies the synchronized shadow values into the 
	# actual physics properties inside integrate_forces
	if is_multiplayer_authority():
		sync_position = position
		sync_rotation = rotation
		sync_linear_velocity = linear_velocity
		sync_angular_velocity = angular_velocity
	else:
		position = sync_position
		rotation = sync_rotation
		linear_velocity = sync_linear_velocity
		angular_velocity = sync_angular_velocity
