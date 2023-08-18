extends RayCast2D

## Emits information from the raycast.
signal hit(hit: bool, point: Vector2)

# Do the raycast test.
func _physics_process(delta: float) -> void:
	# Get the hit point.
	var point := get_collision_point()
	# If there was a collision emit true to the signal.
	if is_colliding(): hit.emit(true, point)
	# If there wasn't a collision emit false to the signal.
	else: hit.emit(false, point)
	# Remove the raycast.
	queue_free()
