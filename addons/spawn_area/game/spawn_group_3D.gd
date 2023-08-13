@tool
class_name SpawnGroup3D
extends Node3D

@export var spawn_style: SpawnGroup.SpawnStyle = SpawnGroup.SpawnStyle.All:
	set(value):
		spawn_style = value
		if spawn_style == SpawnGroup.SpawnStyle.Seed:
			_rng.seed = hash(seed)
		notify_property_list_changed()

signal spawned(item: Node3D)

## The seed to use when [code]spawn_style[/code] is set to [code]Seed[/code].
var seed: String = ''
# An array is used so the value can be modified by reference.
var _idx: Array[int] = [0]
var _rng := RandomNumberGenerator.new()

## Picks a [code]SpawnArea3D[/code] node based on the spawn style, and spawns the item in it.
##
## To change the spawn style, change the [code]spawn_style[/code] property.
## [code]
##    @export var unit: PackedScene
##    @onready var group: SpawnGroup3D = $SpawnGroup3D
## 		func _ready() -> void:
## 			group.spawned.connect(_on_spawned)
## 			group.spawn(unit)
## 		func _on_spawned(item: Node3D) -> void:
## 			item.reparent(units)
## 		item.reparent(units)
## [/code]
func spawn(item: PackedScene):
	var children := find_children('', 'SpawnArea3D')
	var spawnArea := SpawnGroup.pick_area(children, spawn_style, _rng, _idx)
	if spawnArea is Array:
		for area in spawnArea as Array[SpawnArea3D]:
			area.spawn(item)
	else:
		(spawnArea as SpawnArea3D).spawn(item)



## Sets up the signals on the [code]SpawnGroup3D[/code] node for when child [code]SpawnArea3D[/code] nodes are added to the scene.
func _ready() -> void:
	if not Engine.is_editor_hint():
		child_entered_tree.connect(_on_child_entered_tree)
		var children := find_children('', 'SpawnArea3D')
		for child in children:
			_on_child_entered_tree(child)



## Sets up the signal to be emitted when a [code]SpawnArea3D[/code] node spawns an item.
func _on_child_entered_tree(child: Node) -> void:
	if child is SpawnArea3D:
		child.spawned.connect(_on_spawned)



## Emits the [code]spawned[/code] signal when a [code]SpawnArea3D[/code] node spawns an item.
func _on_spawned(item: Node3D) -> void:
	spawned.emit(item)



func _get_property_list() -> Array[Dictionary]:
	var list: Array[Dictionary] = []

	if spawn_style == SpawnGroup.SpawnStyle.Seed:
		list.push_back({
			name = 'seed',
			type = TYPE_STRING,
		})

	return list
