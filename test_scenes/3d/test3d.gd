extends Node3D

@export var unit: PackedScene

@onready var group: SpawnGroup3D = $SpawnGroup3D
@onready var timer: Timer = $Timer
@onready var units: Node3D = $Units

func _ready() -> void:
	timer.timeout.connect(_on_create)
	group.spawned.connect(_on_spawned)

func _on_create():
	group.spawn(unit)

func _on_spawned(node: Node) -> void:
	node.reparent(units)
