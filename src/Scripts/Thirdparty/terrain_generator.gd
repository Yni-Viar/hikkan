class_name TerrainGenerator
extends Resource

const RANDOM_BLOCK_PROBABILITY = 0.00390625

static func empty() -> Dictionary:
	return {}


static func random_blocks() -> Dictionary:
	var random_data := {}
	for x in Chunk.CHUNK_SIZE:
		for y in Chunk.CHUNK_SIZE:
			for z in Chunk.CHUNK_SIZE:
				var vec := Vector3i(x, y, z)
				if randf() < RANDOM_BLOCK_PROBABILITY:
					random_data[vec] = randi() % 29 + 1

	return random_data
