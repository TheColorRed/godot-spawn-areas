extends RayCast2D

## Emits information from the raycast.
signal hit(hit: bool, item: PackedScene, point: Vector2)

## The item that will be spawned.
var item: PackedScene

# Do the raycast test.
func _physics_process(delta: float) -> void:
	# Get the hit point.
	var point := get_collision_point()
	# If there was a collision emit true to the signal.
	if is_colliding(): hit.emit(true, item, point)
	# If there wasn't a collision emit false to the signal.
	else: hit.emit(false, item, point)
	# Remove the raycast.
	queue_free()
