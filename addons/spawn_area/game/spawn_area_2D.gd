@tool
class_name SpawnArea2D extends Node2D

const RayCastTest2D := preload('res://addons/spawn_area/game/raycast_2D.gd')
const SG := preload('res://addons/spawn_area/game/spawn_group_2D.gd')

signal spawned(node: Node)

enum Shape {
	Rectangle,  ## A 2d rectangle.
	Circle,     ## A 2d circle.
	Line,       ## line that works in 3d and 2d scenes.
	Point       ## A small point.
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
	y  ## The direction of a ray on the Y axis.
}

const _color = Color('#ff8f47')
const _color_ray = Color('#ff00e1')
var _rect: Rect2 = Rect2(Vector2(0 - (100 / 2.0), 0 - (100 / 2.0)), Vector2(100, 100))
## The shape of the spawn area.
@export var shape: Shape = Shape.Rectangle:
	set(value):
		shape = value
		queue_redraw()
		notify_property_list_changed()
	get: return shape
## The size of the shape.
var size: Vector2 = Vector2(100, 100):
	set(value):
		var x = clamp(value.x, 0, INF)
		var y = clamp(value.y, 0, INF)
		size = Vector2(x, y)
		_rect = Rect2(
			Vector2(0 - (x / 2.0), 0 - (y / 2.0)),
			Vector2(x, y)
		)
		queue_redraw()
## The radius of the circle or sphere.
var radius: float = 50:
	set(value):
		radius = value
		queue_redraw()
		notify_property_list_changed()
## The length of the line.
var length: float = 100:
	set(value):
		length = value
		queue_redraw()
		notify_property_list_changed()
## The direction of the line.
var direction: LineDirection = LineDirection.Horizontal:
	set(value):
		direction = value
		queue_redraw()
		notify_property_list_changed()
## How the shape should spawn items.
var spawn_location: SpawnLocation = SpawnLocation.Inside
## Whether or not to use a raycast to detect a collision with a body or area.
## This is useful for creating items on an uneven surface.
##
## A raycast is most optimal when used with a [code]line[/code], as nothing is usually created
## within the shape when using a raycast since the point is generated off of areas and bodies.
## Thus a sphere with a radius of [code]50[/code] and a line of a length of [code]100[/code] will end in the same
## location when a raycast is used.
var is_raycast: bool = false:
	set(value):
		is_raycast = value
		queue_redraw()
		notify_property_list_changed()
	get: return is_raycast
## The direction that the ray should go.
var ray_direction: RayDirection = RayDirection.y:
	set(value):
		ray_direction = value
		queue_redraw()
		notify_property_list_changed()
## The position of where the ray will originate relative to the spawn area origin.
var ray_start = 500
## The length of the ray from the start position.
var ray_length = 1000
## The ray mask to only test for items that are on the same layer.
var ray_mask: int = 1
## Whether or not the ray should collide with areas.
var collide_with_areas: bool = true
## Whether or not the ray should collide with bodies.
var collide_with_bodies: bool = true
## Whether or not the ray should retry if the test was a miss.
##
## If enabled, this could take a long time to get a position if there
## is more empty space than bodies/areas within the shape.
var retry_on_miss: bool = false
## The weight of the item. This is used for [code]SpawnGroup2D[/code] weighted spawning.
var weight: int = 1


## Spawns the item randomly within the node.
## Returns the newly created item.
##
## Use the following to change the items parent.
## [codeblock]
## 		var item = area.spawn(unit)
## 		item.reparent(units)
## [/codeblock]
func spawn(item: Variant) -> void:
	var point: Variant = Vector2.ZERO
	if shape == Shape.Rectangle: point = _get_position_on_rectangle(item)
	elif shape == Shape.Circle: point = _get_position_on_circle(item)
	elif shape == Shape.Line: point = _get_position_on_line(item)
	elif shape == Shape.Point: point = _get_position_on_point(item)

	# If the value is null then the item is being created with a raycast.
	if point == null: return

	if item is PackedScene: _create_instance(item, point)
	else:	item.position = point



## Creates the packed scene instance
func _create_instance(item: Variant, point: Vector2, world_coords: bool = false) -> void:
	if item is PackedScene:
		var inst := item.instantiate() as Node2D
		add_child(inst)
		if world_coords == false: inst.position = point
		else: inst.global_position = point
		spawned.emit(inst)
	else:
		if world_coords == false: item.position = point
		else: item.global_position = point
		spawned.emit(item)



## Gets the point of where the item will spawn on a rectangle.
##
## If [null] is returned, then a ray is being used and the ray will handle the position.
func _get_position_on_rectangle(item: Variant) -> Variant:
	var point := _rect.position
	var s := _rect.size
	if spawn_location == SpawnLocation.Inside:
		point.x = randf_range(-s.x / 2.0, s.x / 2.0)
		point.y = randf_range(-s.y / 2.0, s.y / 2.0)
	elif spawn_location == SpawnLocation.Perimeter:
		var side := randi_range(1, 4) # 1=left; 2=top; 3=right; 4=bottom
		match side:
			1:
				point.x = -s.x / 2.0
				point.y = randf_range(-s.y / 2.0, s.y / 2.0)
			2:
				point.x = randf_range(-s.x / 2.0, s.x / 2.0)
				point.y = -s.y / 2.0
			3:
				point.x = s.x / 2.0
				point.y = randf_range(-s.y / 2.0, s.y / 2.0)
			4:
				point.y = s.y / 2.0
				point.x = randf_range(-s.x / 2.0, s.x / 2.0)
	if is_raycast:
		_raycast_test(point, item)
		return null
	return point



## Gets the point of where the item will spawn on a circle.
func _get_position_on_circle(item: Variant) -> Variant:
	var point := Vector2.ZERO
	if spawn_location == SpawnLocation.Inside:
		# https://stackoverflow.com/questions/5837572/generate-a-random-point-within-a-circle-uniformly
		var r := radius * sqrt(randf())
		var theta := randf() * 2.0 * PI
		point.x = point.x + r * cos(theta)
		point.y = point.y + r * sin(theta)
	elif spawn_location == SpawnLocation.Perimeter:
		# https://stackoverflow.com/questions/9879258/how-can-i-generate-random-points-on-a-circles-circumference-in-javascript
		var angle := randf() * PI * 2
		point.x = cos(angle) * radius
		point.y = sin(angle) * radius

	if is_raycast:
		_raycast_test(point, item)
		return null
	return point



## Gets the position to create the item on a line.
func _get_position_on_line(item: Variant) -> Variant:
	var point := position

	if direction == LineDirection.Horizontal:
		point = Vector2(randf_range(-length / 2.0, length / 2.0), 0)
	elif direction == LineDirection.Vertical:
		point = Vector2(0, randf_range(-length / 2.0, length / 2.0))

	if is_raycast:
		_raycast_test(point, item)
		return null
	return point



## Gets the position to create the item on a point.
func _get_position_on_point(item: Variant) -> Variant:
	if is_raycast:
		_raycast_test(Vector2.ZERO, item)
		return null
	return Vector2.ZERO



## Does a raycast test if [is_raycast] is [true].
func _raycast_test(spawn_location_from_ray: Vector2, item: Variant) -> void:
	# Raycasting is disabled, so this is a valid location.
	if not is_raycast: return

	var dir: String = RayDirection.keys()[ray_direction]
	# Setup the Raycast
	var ray := RayCast2D.new()
	ray.position = Vector2(spawn_location_from_ray.x, spawn_location_from_ray.y)
	ray.target_position = Vector2(0, 0)
	ray.position[dir] = -ray_start
	ray.target_position[dir] = ray_length
	ray.collide_with_areas = collide_with_areas
	ray.collide_with_bodies = collide_with_bodies
	ray.collision_mask = ray_mask

	# Setup the Raycast script and attach the spawnable item.
	ray.set_script(RayCastTest2D)
	ray.hit.connect(_hit_result)
	ray.item = item

	# Add the Raycast to the scene.
	add_child(ray)



## This gets triggered from the raycast.
func _hit_result(hit: bool, item: Variant, point: Vector2) -> void:
	if hit: _create_instance(item, point, true)
	else: if retry_on_miss: spawn(item)



## Draws the shape of the spawn area and the raycast if enabled.
func _draw() -> void:
	if Engine.is_editor_hint():
		# Draw the shape of the spawn area.
		if shape == Shape.Rectangle:
			draw_rect(_rect, _color, false, 1)
		elif shape == Shape.Circle:
			draw_arc(Vector2.ZERO , radius, 0, 360, 360, _color)
		elif shape == Shape.Line:
			if direction == LineDirection.Horizontal:
				draw_line(Vector2(-length / 2.0, 0), Vector2(length / 2.0, 0), _color)
			elif direction == LineDirection.Vertical:
				draw_line(Vector2(0,-length / 2.0), Vector2(0, length / 2.0), _color)
		elif shape == Shape.Point:
			draw_circle(Vector2.ZERO, 3, _color)

		# Draw the raycast if enabled.
		if is_raycast:
			_draw_arrow(Vector2.ZERO)



## Draws an arrow at the starting point.
func _draw_arrow(start: Vector2) -> void:
	var len := 25
	if ray_direction == RayDirection.x:
		draw_line(start, Vector2(len + start.x, 0), _color_ray)
		draw_line(Vector2(len + start.x, 0), Vector2(15 + start.x - start.y, -10), _color_ray)
		draw_line(Vector2(len + start.x, 0), Vector2(15 + start.x - start.y, 10), _color_ray)
	elif ray_direction == RayDirection.y:
		draw_line(start, Vector2(0, len + start.y), _color_ray)
		draw_line(Vector2(0, len + start.y), Vector2(-10, 15 + start.y - start.x), _color_ray)
		draw_line(Vector2(0, len + start.y), Vector2(10, 15 + start.y - start.x), _color_ray)



## Checks if the node has a parent of a specific type.
func _has_parent(node: Variant, parent: Variant) -> bool:
	if node.get_parent() == null: return false
	if node.get_parent() is SG: return true
	return _has_parent(node.get_parent(), parent)



## Gets the property list to display in the editor.
func _get_property_list() -> Array[Dictionary]:
	var props: Array[Dictionary] = []

	if shape != Shape.Line && shape != Shape.Point:
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
	elif shape == Shape.Circle:
		props.append({ name = 'radius', type = TYPE_FLOAT })
	elif shape == Shape.Rectangle:
		props.append({ name = 'size', type = TYPE_VECTOR2I })


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
			name = 'ray_direction',
			type = TYPE_INT,
			hint = PROPERTY_HINT_ENUM,
			hint_string = 'x,y'
		})
		props.append({
			name = 'ray_start',
			type = TYPE_INT,
		})
		props.append({
			name = 'ray_length',
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

	if _has_parent(self, SpawnGroup2D):
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
