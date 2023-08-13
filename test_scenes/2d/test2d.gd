extends Node2D

## A reference to the unit scene. This scene will be instanced when a unit is spawned.
@export var unit: PackedScene

## A reference to the spawn group. This group has multiple spawn areas,
## and will spawn units in one or more of them (depending on the spawn group's spawn style).
@onready var group: SpawnGroup2D = $SpawnGroup2D
## A reference to the timer. When the timer times out, a unit will be spawned.
@onready var timer: Timer = $Timer
## A reference to the units node. When a unit is spawned, it will be reparented to this node.
@onready var units: Node2D = $Units

# Connects the signals for the timer and the spawn group.
func _ready() -> void:
	timer.timeout.connect(_on_create)
	group.spawned.connect(_on_spawned)

# When the timer times out, spawn a unit.
func _on_create():
	group.spawn(unit)

# When a unit is spawned, reparent it to the units node.
func _on_spawned(node: Node2D) -> void:
	node.reparent(units)
