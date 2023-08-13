@tool
class_name SpawnArea3D extends Node3D

const RayCastTest3D := preload('res://addons/spawn_area/game/raycast_3D.gd')
const SG := preload('res://addons/spawn_area/game/spawn_group_3D.gd')

signal spawned(node: Node)

enum Shape {
	Plane,  ## A flat 2d rectangle or circle that works in 3d and 2d scenes.
	Line,   ## line that works in 3d and 2d scenes.
	Box,    ## A 3d box that works best in 3d scenes.
	Sphere  ## A 3d sphere that works best in 3d scenes.
}

enum PlaneShape {
	Rectangle, ## A rectangle with four sides.
	Circle     ## A circle based on PI.
}

enum SpawnLocation {
	Inside,    ## Creates items within the shape.
	Perimeter  ## Creates items on the perimeter of the shape.
}

enum LineDirection {
	Horizontal, ## The direction of a line on the horizontal axis (Y).
	Vertical    ## The direction of a line on the vertical axis (X).
}

enum RayDirection {
	x, ## The direction of a ray on the X axis.
	y, ## The direction of a ray on the Y axis.
	z  ## The direction of a ray on the Z axis (only available in 3d mode).
}

## The shape of the spawn area.
@export var shape: Shape = Shape.Plane:
	set(value):
		shape = value
		notify_property_list_changed()
	get: return shape
## The size of the shape.
var size: Variant = Vector3.ONE:
	set(value):
		if value is Vector3:
			size = Vector3(
				clampf(value.x, 0, INF),
				clampf(value.y, 0, INF),
				clampf(value.z, 0, INF)
			)
		elif value is Vector2:
			size = Vector2(
				clampf(value.x, 0, INF),
				clampf(value.y, 0, INF)
			)
		notify_property_list_changed()
## The radius of the circle or sphere.
var radius: float = 1:
	set(value):
		radius = value
		notify_property_list_changed()
## The length of the line.
var length: float = 1:
	set(value):
		length = value
		notify_property_list_changed()
## The direction of the line.
var direction: LineDirection = LineDirection.Horizontal:
	set(value):
		direction = value
		notify_property_list_changed()
## The shape of the plane.
var plane_shape: PlaneShape = PlaneShape.Rectangle:
	set(value):
		plane_shape = value
		notify_property_list_changed()
	get: return plane_shape
## How the shape should spawn items.
var spawn_location: SpawnLocation = SpawnLocation.Inside
## Whether or not to use a ray cast to detect a collision with a body or area.
## This is useful for creating items on an uneven surface.
var is_raycast: bool = false:
	set(value):
		is_raycast = value
		notify_property_list_changed()
	get: return is_raycast
## Whether or not the ray should be a 3D test or a 2D test.
var is_2D: bool = false:
	set(value):
		is_2D = value
		if ray_direction == RayDirection.z:
			ray_direction = RayDirection.y
		notify_property_list_changed()
## The direction that the ray should go.
var ray_direction: RayDirection = RayDirection.y
## The ray distance from the spawn area origin.
var ray_height = 500
## The ray mask to only test for items that are on the same layer.
var ray_mask: int = 1
## Whether or not the ray should collide with areas.
var collide_with_areas: bool = true
## Whether or not the ray should collide with bodies.
var collide_with_bodies: bool = true
## Whether or not the ray should retry if the test was a miss.
## [br][br]
## If enabled, this could take a long time to get a position if there
## is more empty space than bodies/areas within the shape.
var retry_on_miss: bool = false
## The weight of the item. This is used for [code]SpawnGroup2D[/code] weighted spawning.
var weight: int = 1


## Spawns the item randomly within the node.
## Returns the newly created item.
##
## Use the following to change the items parent.
## [code]
## 		var item = area.spawn(unit)
## 		item.reparent(units)
## [/code]
func spawn(item: PackedScene) -> void:
	var point: Variant = Vector3.ZERO
	if shape == Shape.Plane: point = _get_position_on_plane(item)
	elif shape == Shape.Line: point = _get_position_on_line(item)
	elif shape == Shape.Sphere: point = _get_position_in_sphere(item)
	elif shape == Shape.Box: point = _get_position_in_box(item)

	# If the value is null then the item is being created with a raycast test.
	if point == null: return

	_create_instance(item, point)



## Creates the packed scene instance
func _create_instance(item: PackedScene, point: Vector3) -> void:
	var inst := item.instantiate()
	inst.position = point
	add_child(inst)
	spawned.emit(inst)



## Gets the point of where the item will spawn.
##
## If [null] is returned, then a ray is being used and the ray will handle the new position.
func _get_position_on_plane(item: PackedScene) -> Variant:
	var point := position
	if plane_shape == PlaneShape.Rectangle:
		if spawn_location == SpawnLocation.Inside:
			point.x += randf_range(-size.x / 2.0, size.x / 2.0)
			point.z += randf_range(-size.y / 2.0, size.y / 2.0)
		elif spawn_location == SpawnLocation.Perimeter:
			var side := randi_range(1, 4) # 1=left; 2=top; 3=right; 4=bottom
			match side:
				1:
					point.x = -size.x
					point.z = randf_range(-size.y / 2.0, size.y / 2.0)
				2:
					point.x = randf_range(-size.x / 2.0, size.x / 2.0)
					point.z = -size.y
				3:
					point.x = size.x
					point.z = randf_range(-size.y / 2.0, size.y / 2.0)
				4:
					point.z = size.y
					point.x = randf_range(-size.x / 2.0, size.x / 2.0)
	elif plane_shape == PlaneShape.Circle:
		if spawn_location == SpawnLocation.Inside:
			# https://stackoverflow.com/questions/5837572/generate-a-random-point-within-a-circle-uniformly
			var r := radius * sqrt(randf())
			var theta := randf() * 2.0 * PI
			point.x = point.x + r * cos(theta)
			point.z = point.z + r * sin(theta)
		elif spawn_location == SpawnLocation.Perimeter:
			# https://stackoverflow.com/questions/9879258/how-can-i-generate-random-points-on-a-circles-circumference-in-javascript
			var angle := randf() * PI * 2
			point.x = cos(angle) * radius
			point.z = sin(angle) * radius

	if is_raycast:
		_raycast_test(point, item)
		return null
	return point



## Gets the position to create the scene on a line.
func _get_position_on_line(item: PackedScene):
	var point := position

	if direction == LineDirection.Horizontal:
		point = Vector3(randf_range(-length / 2.0, length / 2.0), 0, 0)
	elif direction == LineDirection.Vertical:
		point = Vector3(0, randf_range(-length / 2.0, length / 2.0), 0)

	if is_raycast:
		_raycast_test(point, item)
		return null
	return point



## Gets the position to create the scene in a box.
func _get_position_in_box(item: PackedScene):
	var point := position

	if spawn_location == SpawnLocation.Inside:
		point = Vector3(
			randf_range(-size.y / 2.0, size.y / 2.0),
			randf_range(-size.x / 2.0, size.x / 2.0),
			randf_range(-size.z / 2.0, size.z / 2.0),
		)
	elif spawn_location == SpawnLocation.Perimeter:
		var side := randi_range(1, 6)
		match side:
			1:
				point.x = -size.x
				point.y = randf_range(-size.y, size.y)
				point.z = randf_range(-size.z, size.z)
			2:
				point.x = randf_range(-size.x, size.x)
				point.y = randf_range(-size.y, size.y)
				point.z = -size.z
			3:
				point.x = size.x
				point.y = randf_range(-size.y, size.y)
				point.z = randf_range(-size.z, size.z)
			4:
				point.x = randf_range(-size.z, size.z)
				point.y = randf_range(-size.y, size.y)
				point.z = size.z
			5:
				point.x = randf_range(-size.x, size.x)
				point.y = size.y
				point.z = randf_range(-size.z, size.z)
			6:
				point.x = randf_range(-size.x, size.x)
				point.y = -size.y
				point.z = randf_range(-size.z, size.z)


	if is_raycast:
		_raycast_test(point, item)
		return null
	return point



## Gets the position to create the scene in a sphere.
func _get_position_in_sphere(item: PackedScene):
	var point := position
	if spawn_location == SpawnLocation.Inside:
		var r := radius * randf()
		# Get a random direction
		# From Three.js https://github.com/mrdoob/three.js/blob/0b169138a99655148ed9601f87c685da54997155/src/math/Vector3.js#L696-L710
		var u := (randf() - 0.5) * 2;
		var t := randf() * PI * 2;
		var f := sqrt(1 - u ** 2);
		point.x = f * cos( t );
		point.y = f * sin( t );
		point.z = u;
		# Scale the vector to match the random radius
		point.x *= r
		point.y *= r
		point.z *= r

	elif spawn_location == SpawnLocation.Perimeter:
		var u := randf()
		var v := randf()
		var theta := 2 * PI * u
		var phi := acos(2 * v - 1)
		var x := point.x + (radius * sin(phi) * cos(theta))
		var y := point.y + (radius * sin(phi) * sin(theta))
		var z := point.z + (radius * cos(phi))
		point = Vector3(x,y,z)

	if is_raycast:
		_raycast_test(point, item)
		return null
	return point



## Does a raycast test if [is_raycast] is [true].
func _raycast_test(spawn_location: Vector3, item: PackedScene):
	# Raycasting is disabled, so this is a valid location.
	if not is_raycast: return

		# Setup the Raycast
	var ray := RayCast3D.new()
	ray.position = spawn_location
	ray.position[ray_direction] += ray_height
	ray.target_position[ray_direction] = -(ray_height * 2)
	ray.collide_with_areas = collide_with_areas
	ray.collide_with_bodies = collide_with_bodies
	ray.debug_shape_custom_color = Color('#ff00e1')
	ray.debug_shape_thickness = 2
	ray.collision_mask = ray_mask

	# Setup the Raycast script and attach the spawnable item.
	ray.set_script(RayCastTest3D)
	ray.hit.connect(_hit_result)
	ray.item = item
#	return ray

	# Add the Raycast to the scene.
	add_child(ray)



## This gets triggered from the raycast.
func _hit_result(hit: bool, item: PackedScene, point: Vector3) -> void:
	if hit: _create_instance(item, point)
	else: if retry_on_miss: spawn(item)



## Checks if the node has a parent of a specific type.
func _has_parent(node: Variant, parent: Variant) -> bool:
	if node.get_parent() == null: return false
	if node.get_parent() is SG: return true
	return _has_parent(node.get_parent(), parent)



## Gets the property list to display in the editor.
func _get_property_list() -> Array[Dictionary]:
	var props: Array[Dictionary] = []

	if shape != Shape.Line:
		props.append({
			name = 'spawn_location',
			type = TYPE_INT,
			hint = PROPERTY_HINT_ENUM,
			hint_string = 'Inside,Perimeter'
		})
	if shape == Shape.Line:
		props.append({
			name = 'length',
			type = TYPE_FLOAT,
		})
		props.append({
			name = 'direction',
			type = TYPE_INT,
			hint = PROPERTY_HINT_ENUM,
			hint_string = 'Horizontal,Vertical'
		})
	if shape == Shape.Plane:
		props.append({
			name = 'plane_shape',
			type = TYPE_INT,
			hint = PROPERTY_HINT_ENUM,
			hint_string = 'Rectangle,Circle'
		})
		if plane_shape == PlaneShape.Circle:
			props.append({ name = 'radius', type = TYPE_FLOAT })
		else:
			props.append({ name = 'size', type = TYPE_VECTOR2 })
	if shape == Shape.Box:
		props.append({
			name = 'size',
			type = TYPE_VECTOR3
		})
	if shape == Shape.Sphere:
		props.append({
			name = 'radius',
			type = TYPE_FLOAT
		})

	props.append({
		name = 'Raycast',
		type = TYPE_NIL,
		usage = PROPERTY_USAGE_GROUP
	})
	props.append({
		name = 'is_raycast',
		type = TYPE_BOOL
	})
	if is_raycast:
		props.append({
			name = 'is_2D',
			type = TYPE_BOOL
		})
		if is_2D:
			props.append({
				name = 'ray_direction',
				type = TYPE_INT,
				hint = PROPERTY_HINT_ENUM,
				hint_string = 'x,y'
			})
		else:
			props.append({
				name = 'ray_direction',
				type = TYPE_INT,
				hint = PROPERTY_HINT_ENUM,
				hint_string = 'x,y,z'
			})
		props.append({
			name = 'ray_height',
			type = TYPE_INT,
		})
		props.append({
			name = 'ray_mask',
			type = TYPE_INT,
			hint = PROPERTY_HINT_LAYERS_3D_PHYSICS,
			hint_string = '%d' % 1
		})
		props.append({
			name = 'collide_with_areas',
			type = TYPE_BOOL,
			hint = PROPERTY_HINT_NONE,
			usage = PROPERTY_USAGE_DEFAULT,
			hint_string = 'false'
		})
		props.append({
			name = 'collide_with_bodies',
			type = TYPE_BOOL,
			hint_string = 'true'
		})
		props.append({
			name = 'retry_on_miss',
			type = TYPE_BOOL,
		})

	if _has_parent(self, SpawnGroup3D):
		props.append({
			name = 'Spawn Group Settings',
			type = TYPE_NIL,
			usage = PROPERTY_USAGE_GROUP
		})
		props.append({
			name = 'weight',
			type = TYPE_INT,
		})

	return props
