class_name SpawnAreaGizmo3D
extends EditorNode3DGizmoPlugin

const SpawnArea3D = preload('res://addons/spawn_area/game/spawn_area_3D.gd')

const color := Color('#ff8f47')
var lines := PackedVector3Array()
var handles := PackedVector3Array()
var gizmo: EditorNode3DGizmo
var size := Vector3.ONE



func _has_gizmo(node: Node3D) -> bool:
	if node is SpawnArea3D:
		if not node.property_list_changed.is_connected(_prop_list_changed):
			node.property_list_changed.connect(_prop_list_changed)
		return true
	return false



func _get_gizmo_name() -> String: return 'SpawnArea3D'



func _prop_list_changed():
	if gizmo != null: _redraw(gizmo)



func _init():
	create_material('main', color)
	create_handle_material('handles')



func _redraw(_gizmo: EditorNode3DGizmo) -> void:
	gizmo = _gizmo
	gizmo.clear()
	lines = PackedVector3Array()
	handles = PackedVector3Array()
	var node := gizmo.get_node_3d() as SpawnArea3D

	if node.shape == node.Shape.Plane:
		_draw_gizmo_plane(gizmo)
	elif node.shape == node.Shape.Sphere:
		_draw_gizmo_sphere(gizmo)
	elif node.shape == node.Shape.Box:
		_draw_gizmo_box(gizmo)
	elif node.shape == node.Shape.Line:
		_draw_gizmo_line(gizmo)

	gizmo.add_lines(lines, get_material('main', gizmo))
	gizmo.add_handles(handles, get_material('handles', gizmo), [])



func _draw_gizmo_plane(gizmo: EditorNode3DGizmo):
	var node := gizmo.get_node_3d() as SpawnArea3D
	var p := node.position as Vector3

	if node.plane_shape == node.PlaneShape.Rectangle:
		_draw_face(node.position, Vector2(node.size.x / 2.0, node.size.y / 2.0))
		# Setup the handles
		handles.push_back(Vector3(abs(node.size.x) / 2.0, p.y, 0))  # x handle
		handles.push_back(Vector3(0, p.y, abs(node.size.y) / 2.0))  # z handle
	elif node.plane_shape == node.PlaneShape.Circle:
		if node.radius <= 0: node.radius = 0
		handles.push_back(Vector3(p.x, p.y, node.radius))
		_draw_circle(node.position, node.radius,'y')



func _draw_gizmo_line(gizmo: EditorNode3DGizmo):
	var node := gizmo.get_node_3d() as SpawnArea3D

	var vec1 := Vector3.ZERO
	var vec2 := Vector3.ZERO
	if node.direction == node.LineDirection.Horizontal:
		handles.push_back(Vector3(node.length / 2.0, 0, 0))
		vec1 = Vector3(node.length / 2.0, 0, 0)
		vec2 = Vector3(-node.length / 2.0, 0, 0)
	elif node.direction == node.LineDirection.Vertical:
		handles.push_back(Vector3(0, node.length / 2.0, 0))
		vec1 = Vector3(0, node.length / 2.0, 0)
		vec2 = Vector3(0, -node.length / 2.0, 0)
	_draw_line(vec1, vec2)



func _draw_gizmo_sphere(gizmo: EditorNode3DGizmo):
	var node := gizmo.get_node_3d() as SpawnArea3D
	var p := node.position as Vector3

	if node.radius <= 0: node.radius = 0
	handles.push_back(Vector3(p.x, p.y, node.radius))

	_draw_circle(node.position, node.radius, 'x')
	_draw_circle(node.position, node.radius, 'y')
	_draw_circle(node.position, node.radius, 'z')



func _draw_gizmo_box(gizmo: EditorNode3DGizmo):
	var node := gizmo.get_node_3d() as SpawnArea3D
	handles.push_back(Vector3(node.size.x / 2.0, 0, 0))
	handles.push_back(Vector3(0, node.size.y / 2.0, 0))
	handles.push_back(Vector3(0, 0, node.size.z / 2.0))

	var vec1 := Vector3.ZERO
	var vec2 := Vector3.ZERO

	# top left
	vec1 = Vector3(-node.size.x, node.size.y, -node.size.z) / 2.0
	vec2 = Vector3(-node.size.x, node.size.y, node.size.z) / 2.0
	_draw_line(vec1, vec2)
	# top right
	vec1 = Vector3(node.size.x, node.size.y, -node.size.z) / 2.0
	vec2 = Vector3(node.size.x, node.size.y, node.size.z) / 2.0
	_draw_line(vec1, vec2)
	# top back
	vec1 = Vector3(-node.size.x, node.size.y, -node.size.z) / 2.0
	vec2 = Vector3(node.size.x, node.size.y, -node.size.z) / 2.0
	_draw_line(vec1, vec2)
	# top forward
	vec1 = Vector3(-node.size.x, node.size.y, node.size.z) / 2.0
	vec2 = Vector3(node.size.x, node.size.y, node.size.z) / 2.0
	_draw_line(vec1, vec2)
	# bottom left
	vec1 = Vector3(-node.size.x, -node.size.y, -node.size.z) / 2.0
	vec2 = Vector3(-node.size.x, -node.size.y, node.size.z) / 2.0
	_draw_line(vec1, vec2)
	# bottom right
	vec1 = Vector3(node.size.x, -node.size.y, -node.size.z) / 2.0
	vec2 = Vector3(node.size.x, -node.size.y, node.size.z) / 2.0
	_draw_line(vec1, vec2)
	# bottom back
	vec1 = Vector3(-node.size.x, -node.size.y, -node.size.z) / 2.0
	vec2 = Vector3(node.size.x, -node.size.y, -node.size.z) / 2.0
	_draw_line(vec1, vec2)
	# bottom forward
	vec1 = Vector3(-node.size.x, -node.size.y, node.size.z) / 2.0
	vec2 = Vector3(node.size.x, -node.size.y, node.size.z) / 2.0
	_draw_line(vec1, vec2)


	# front right
	vec1 = node.size / 2.0
	vec2 = Vector3(node.size.x, -node.size.y, node.size.z) / 2.0
	_draw_line(vec1, vec2)
	# back left
	vec1 = -node.size / 2.0
	vec2 = Vector3(-node.size.x, node.size.y, -node.size.z) / 2.0
	_draw_line(vec1, vec2)
	# back right
	vec1 = Vector3(node.size.x, node.size.y, -node.size.z) / 2.0
	vec2 = Vector3(node.size.x, -node.size.y, -node.size.z) / 2.0
	_draw_line(vec1, vec2)
	# front left
	vec1 = Vector3(-node.size.x, node.size.y, node.size.z) / 2.0
	vec2 = Vector3(-node.size.x, -node.size.y, node.size.z) / 2.0
	_draw_line(vec1, vec2)



func _draw_circle(origin: Vector3, circle_radius: float, axis: String):
	var nb_points := 360
	var points_arc := PackedVector2Array()

	# Generate the points
	for i in range(nb_points + 1):
		var angle_point := deg_to_rad(0 + i * (360-0) / nb_points - 90)
		points_arc.push_back(Vector2(origin.x,origin.y) + Vector2(cos(angle_point), sin(angle_point)) * circle_radius)

	# Draw the lines
	for index_point in range(nb_points):
		var point1 := points_arc[index_point]
		var point2 := points_arc[index_point + 1]
		if axis == 'x':
			lines.push_back(Vector3(0, point1.x, point1.y))
			lines.push_back(Vector3(0, point2.x, point2.y))
		elif axis == 'y':
			lines.push_back(Vector3(point1.x, 0, point1.y))
			lines.push_back(Vector3(point2.x, 0, point2.y))
		elif axis == 'z':
			lines.push_back(Vector3(point1.x, point1.y, 0))
			lines.push_back(Vector3(point2.x, point2.y, 0))



func _draw_face(origin: Vector3, size: Vector2):
	var p := origin
	# top
	lines.push_back(Vector3(-size.x, p.y, -size.y))
	lines.push_back(Vector3(size.x, p.y, -size.y))
	# bottom
	lines.push_back(Vector3(size.x, p.y, size.y))
	lines.push_back(Vector3(-size.x, p.y, size.y))
	# left
	lines.push_back(Vector3(-size.x, p.y, -size.y))
	lines.push_back(Vector3(-size.x, p.y, size.y))
	# right
	lines.push_back(Vector3(size.x, p.y, size.y))
	lines.push_back(Vector3(size.x, p.y, -size.y))



func _draw_line(start: Vector3, end: Vector3):
	lines.push_back(start)
	lines.push_back(end)



func _set_handle(gizmo: EditorNode3DGizmo, handle_id: int, secondary: bool, camera: Camera3D, screen_pos: Vector2) -> void:
	var node := gizmo.get_node_3d() as SpawnArea3D
	var handle := handles[handle_id]
	var dist := camera.position.distance_to(handle)
	var p := camera.project_position(screen_pos, dist)
	if node.shape == node.Shape.Line:
		node.length = p.x
	elif node.shape == node.Shape.Plane:
		if node.plane_shape == node.PlaneShape.Circle:
			node.radius = p.z
		elif  node.plane_shape == node.PlaneShape.Rectangle:
			if handle_id == 0: # x
				node.size.x = p.x
			elif handle_id == 1: # z
				node.size.y = p.z
	elif node.shape == node.Shape.Line:
		node.length = p.x
	elif node.shape == node.Shape.Sphere:
		node.radius = p.z
	elif node.shape == node.Shape.Box:
			if handle_id == 0: # x
				node.size.x = p.x
			elif handle_id == 1: # y
				node.size.y = p.y
			elif handle_id == 2: # z
				node.size.z = p.z
	_redraw(gizmo)



func _get_handle_value(gizmo: EditorNode3DGizmo, handle_id: int, secondary: bool) -> Variant:
	var node := gizmo.get_node_3d() as SpawnArea3D
	if node.shape == node.Shape.Plane:
		if node.plane_shape == node.PlaneShape.Circle:
			return node.radius
	if node.shape == node.Shape.Sphere:
		return node.radius
	return node.size



func _commit_handle(gizmo: EditorNode3DGizmo, handle_id: int, secondary: bool, restore: Variant, cancel: bool) -> void:
	var node := gizmo.get_node_3d() as SpawnArea3D
	if node.shape == node.Shape.Plane:
		if node.plane_shape == node.PlaneShape.Circle:
			pass
#			node.radius = radius
	_redraw(gizmo)
