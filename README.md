# SpawnArea

This plugin allows you to create spawn areas and spawn groups for your game.

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

## Spawn Groups

A spawn group is a group of spawn areas that can be used to spawn items in them in multiple ways.

### Spawn Modes

- **All** &ndash; Spawns the item in all spawn areas in the spawn group at the same time.
- **Random** &ndash; Randomly picks a spawn area from the spawn group and spawns the item in it.
- **Round Robin** &ndash; Cycles through the spawn areas in the spawn group and spawns the item in the next spawn area in the cycle.
- **Weighted Random** &ndash; Randomly picks a spawn area from the spawn group based on the spawn area's weight and spawns the item in it (the weight is be set on the spawn area).
- **Seed** &ndash; Randomly picks a spawn area from the spawn group based on the seed and spawns the item in it.
