extends Node3D

@export var unit: PackedScene

@onready var area: SpawnArea3D = $SpawnArea3D
@onready var timer: Timer = $Timer
@onready var units: Node3D = $Units

func _ready() -> void:
	timer.timeout.connect(_on_create)
	area.spawned.connect(_on_spawned)

func _on_create():
	area.spawn(unit)

func _on_spawned(node: Node) -> void:
	node.reparent(units)
