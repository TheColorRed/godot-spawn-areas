class_name SpawnGroup

enum SpawnStyle {
	All, ## Spawns the item in all child [code]SpawnArea2D[/code] nodes at the same time.
	Random, ## Picks a random child [code]SpawnArea2D[/code] node to spawn the item in where each node has an equal chance of being picked.
	RoundRobin, ## Cycles through the child [code]SpawnArea2D[/code] nodes to spawn an item. The child nodes should be in the order you want them to be picked. The first child node will be picked first, then the second, and so on. Once the last child node is picked, it will start over from the first child node.
	WeightedRandom, ## Picks a random child [code]SpawnArea2D[/code] node to spawn the item in, but the probability of picking a node is based on the [code]weight[/code] property of the [code]SpawnArea2D[/code] node. The higher the weight, the more likely it will be picked.
	Seed ## Picks random child [code]SpawnArea2D[/code] based on a [code]seed[/code]. The same seed will always pick the same [code]SpawnArea2D[/code]'s in the same order.
}


## Picks a [code]SpawnArea2D[/code] or [code]SpawnArea3D[/code] and returns the spawn area.
static func pick_area(children: Array, spawn_style: SpawnStyle, rng: RandomNumberGenerator, idx: Array[int]) -> Variant:
	var spawnArea: Variant
	# Pick a SpawnArea2D node based on the spawn style.
	if spawn_style == SpawnGroup.SpawnStyle.Random:
		spawnArea = children.pick_random()
	# Round robin through the SpawnArea2D nodes.
	elif spawn_style == SpawnGroup.SpawnStyle.RoundRobin:
		if idx[0] >= children.size():
			idx[0] = 0
		spawnArea = children[idx[0]]
		idx[0] += 1
	# Spawn in all SpawnArea2D nodes.
	elif spawn_style == SpawnGroup.SpawnStyle.All:
		return children
	# Pick a SpawnArea2D node based on the weight of each node.
	elif spawn_style == SpawnGroup.SpawnStyle.WeightedRandom:
		var total_weight := 0
		for child in children:
			spawnArea = child
			total_weight += spawnArea.weight
		var random := randi() % total_weight
		for child in children:
			spawnArea = child
			random -= spawnArea.weight
			if random <= 0:
				break
	elif spawn_style == SpawnGroup.SpawnStyle.Seed:
		var random := rng.randi_range(0, children.size() - 1)
		spawnArea = children[random]
	return spawnArea