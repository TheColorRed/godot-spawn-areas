# SpawnArea

This plugin allows you to create spawn areas and spawn groups for your game.

- [SpawnArea](#spawnarea)
  - [Spawn Areas](#spawn-areas)
    - [Shapes](#shapes)
      - [2D Shapes](#2d-shapes)
      - [3D Shapes](#3d-shapes)
    - [Spawn Locations](#spawn-locations)
    - [Raycast](#raycast)
    - [Use Cases](#use-cases)
  - [Spawn Groups](#spawn-groups)
    - [Spawn Styles](#spawn-styles)
    - [Use Cases](#use-cases-1)
  - [Examples](#examples)
    - [Spawn Area](#spawn-area)
    - [Spawn Area](#spawn-area-1)
    - [Spawn Group](#spawn-group)

## Spawn Areas

A spawn area is an area that comes in different shapes that can be customized to spawn items in it in multiple ways.

### Shapes

#### 2D Shapes

- **Rectangle** &ndash; A rectangle is a shape with 2 parallel sides and 2 other parallel sides that are perpendicular to the first 2 sides.
- **Circle** &ndash; A circle is a shape with a center and a radius.
- **Line** &ndash; A line is a shape that has a specific length.
- **Point** &ndash; A point is a shape that has no length, width or height. It is just a Vector2 position somewhere in the scene.

#### 3D Shapes

- **Plane** &ndash; A plane is a shape that lies on a flat surface. It has multiple sub-shapes:
  - **Rectangle** &ndash; A rectangle is a shape with 2 parallel sides and 2 other parallel sides that are perpendicular to the first 2 sides.
  - **Circle** &ndash; A circle is a shape with a center and a radius.
  - **Line** &ndash; A line is a shape that has a specific length.
- **Line** &ndash; A line is a shape that has a specific length.
- **Box** &ndash; A box is a shape with 6 sides that are all perpendicular to each other.
- **Sphere** &ndash; A sphere is a shape with a center and a radius.
- **Point** &ndash; A point is a shape that has no length, width or height. It is just a Vector3 position somewhere in the scene.

### Spawn Locations

There are two spawn locations that can be used to spawn items in a spawn area:

- **Inside** &ndash; Spawns the item inside the spawn area.
- **Perimeter** &ndash; Spawns the item on the perimeter of the spawn area.

### Raycast

A raycast can be used to test if an item can be spawned on an area or body. Using a line or plane shape is recommended for when using a raycast since there is less logic to calculate a random point on the shape.

### Use Cases

- For a large world map, you could spawn random animals in random locations on the map.
- For a zombie game, you could spawn zombies around the perimeter of a the player's location (outside of the player's view).

## Spawn Groups

A spawn group is a group of spawn areas that can be used to spawn items in them in multiple ways.

### Spawn Styles

- **All** &ndash; Spawns the item in all spawn areas in the spawn group at the same time.
- **Random** &ndash; Randomly picks a spawn area from the spawn group and spawns the item in it.
- **Round Robin** &ndash; Cycles through the spawn areas in the spawn group and spawns the item in the next spawn area in the cycle.
- **Weighted Random** &ndash; Randomly picks a spawn area from the spawn group based on the spawn area's weight and spawns the item in it (the weight is be set on the spawn area).
- **Seed** &ndash; Randomly picks a spawn area from the spawn group based on the seed and spawns the item in it.

### Use Cases

- A spawn group can be used to spawn items in multiple areas at the same time. For example, you can create a spawn group with multiple spawn areas and spawn an enemy in each them at specific times throughout the gameplay.
- For a player that dies and re-spawns, you can create a spawn group with multiple spawn areas and spawn the player in a random spawn area in the spawn group.
- A player that collects power-ups can have a spawn group with multiple spawn areas and spawn a power-up in a random spawn area in the spawn group.
- A tower defense game could have a spawn group with multiple starting points for the enemies to spawn from. The enemies could be spawned in a round robin style so that they spawn from each starting point in a cycle.
- For a large world map, you could split the areas into smaller areas and create a spawn group with multiple spawn areas. You could then spawn random animals in random locations in the spawn group.

## Examples

### Spawn Area

A spawn area can be created by adding a `SpawnArea2D` or `SpawnArea3D` node to a scene.

### Spawn Area

Creating an item in a spawn area is an easy task. You just have to add the `SpawnArea2D` or `SpawnArea3D` node to the scene and add get the reference to the spawn area in the code. Once you have the reference, you can optionally connect to the `spawned` signal to get the item that was spawned. At any point, you can call the `spawn` method on the spawn area to spawn an item in that spawn area.

**Note:** Using a `SpawnArea2D` or `SpawnArea3D` uses the same code with the only difference being the node type.

```gdscript
extends Node2D

@export var item_scene: PackedScene
@onready var spawn_area := $SpawnArea2D

func _ready() -> void:
  spawn_area.spawned.connect(_on_spawned)
  spawn_area.spawn(item_scene)

func _on_spawned(item: Node) -> void:
  print("Spawned item: ", item.name)
```

### Spawn Group

Creating an item in a spawn group is exactly the same as creating an item in a spawn area on the code side. The only difference is that you have to add the `SpawnGroup2D` or `SpawnGroup3D` node to the scene and add the spawn areas as children of the spawn group.

The spawn group will select a spawn area from the spawn group and spawn the item in it based on the spawn style that is set on the spawn group.

```gdscript
extends Node2D

@export var item_scene: PackedScene
@onready var spawn_group := $SpawnGroup2D

func _ready() -> void:
  spawn_group.spawned.connect(_on_spawned)
  spawn_group.spawn(item_scene)

func _on_spawned(item: Node) -> void:
  print("Spawned item: ", item.name)
```
