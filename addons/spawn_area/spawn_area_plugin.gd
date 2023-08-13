@tool
extends EditorPlugin

# Setup the Gizmo
const Gizmo = preload('res://addons/spawn_area/editor/spawn_area_3D_gizmo.gd')
var gizmo_plugin = Gizmo.new()

# 3d Settings
const node_name_3d     = 'SpawnArea3D'
const spawn_group_3d   = 'SpawnGroup3D'
const spawnArea3d      = preload('res://addons/spawn_area/game/spawn_area_3D.gd')
const spawnAreaIcon3d  = preload('res://addons/spawn_area/icons/spawn_area_3d.png')
const spawnGroup3d     = preload('res://addons/spawn_area/game/spawn_group_3D.gd')
const spawnGroupIcon3d = preload('res://addons/spawn_area/icons/spawn_group_3d.png')

# 2d Settings
const spawn_area_2d    = 'SpawnArea2D'
const spawn_group_2d   = 'SpawnGroup2D'
const spawnArea2d      = preload('res://addons/spawn_area/game/spawn_area_2D.gd')
const spawnAreaIcon2d  = preload('res://addons/spawn_area/icons/spawn_area_2d.png')
const spawnGroup2d     = preload('res://addons/spawn_area/game/spawn_group_2D.gd')
const spawnGroupIcon2d = preload('res://addons/spawn_area/icons/spawn_group_2d.png')

## Setup the plugin when it enters the tree.
func _enter_tree() -> void:
	# Setup 3D plugin tools
	add_custom_type(node_name_3d, 'Node3D', spawnArea3d, spawnAreaIcon3d)
	add_custom_type(spawn_group_3d, 'Node3D', spawnGroup3d, spawnGroupIcon3d)
	add_node_3d_gizmo_plugin(gizmo_plugin)

	# Setup 2D plugin tools
	add_custom_type(spawn_area_2d, 'Node2D', spawnArea2d, spawnAreaIcon2d)
	add_custom_type(spawn_group_2d, 'Node2D', spawnGroup2d, spawnGroupIcon2d)



## Cleanup the plugin when it exits the tree.
func _exit_tree() -> void:
	# Remove 3D plugin tools
	remove_custom_type(node_name_3d)
	remove_custom_type(spawn_group_3d)
	remove_node_3d_gizmo_plugin(gizmo_plugin)

	# Remove 2D plugin tools
	remove_custom_type(spawn_area_2d)
	remove_custom_type(spawn_group_2d)
