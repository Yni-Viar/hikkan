class_name Chunk
extends StaticBody3D
# These chunks are instanced and given data by VoxelWorld.
# After that, chunks finish setting themselves up in the _ready() function.
# If a chunk is changed, its "regenerate" method is called.

const CHUNK_SIZE = 16 # Keep in sync with TerrainGenerator.
const TEXTURE_SHEET_WIDTH = 8

const CHUNK_LAST_INDEX = CHUNK_SIZE - 1
const TEXTURE_TILE_SIZE = 1.0 / TEXTURE_SHEET_WIDTH
const DIRECTIONS: Array[Vector3i] = [Vector3i.LEFT, Vector3i.RIGHT, Vector3i.DOWN, Vector3i.UP, Vector3i.FORWARD, Vector3i.BACK]

var data := {}
var chunk_position := Vector3i()
var is_initial_mesh_generated: bool = false

var _thread: Thread

var primitive_meshes: Array[PrimitiveMesh] = [BoxMesh.new(), PrismMesh.new(), SphereMesh.new()]

@onready var voxel_world := get_parent()


func _ready() -> void:
	transform.origin = Vector3(chunk_position * CHUNK_SIZE)
	name = str(chunk_position)
	data = TerrainGenerator.random_blocks()

	# We can only add colliders in the main thread due to physics limitations.
	#_generate_chunk_collider()


func try_initial_generate_mesh(all_chunks: Dictionary[Vector3i, Chunk]) -> void:
	# We can use a thread for mesh generation.
	for dir in DIRECTIONS:
		if not all_chunks.has(chunk_position + dir):
			return
	is_initial_mesh_generated = true
	_thread = Thread.new()
	_thread.start(_generate_chunk_mesh)


func regenerate() -> void:
	# Clear out all old nodes first.
	for c in get_children():
		remove_child(c)
		c.queue_free()

	# Then generate new ones.
	#_generate_chunk_collider()
	_generate_chunk_mesh()


#func _generate_chunk_collider() -> void:
	#if data.is_empty():
		## Avoid errors caused by StaticBody3D not having colliders.
		#_create_block_collider(Vector3.ZERO)
		#collision_layer = 0
		#collision_mask = 0
		#return
#
	## For each block, generate a collider. Ensure collision layers are enabled.
	#collision_layer = 0xFFFFF
	#collision_mask = 0xFFFFF
	#for block_position: Vector3i in data.keys():
		#var block_id: int = data[block_position]
		#if block_id != 27 and block_id != 28:
			#_create_block_collider(block_position)


func _generate_chunk_mesh() -> void:
	if data.is_empty():
		return
	
	var mesh: PrimitiveMesh
	

	# For each block, add data to the SurfaceTool and generate a collider.
	for block_position: Vector3i in data.keys():
		
		mesh = primitive_meshes[randi_range(0, primitive_meshes.size() - 1)]
		
		var mi := MeshInstance3D.new()
		mi.position = block_position
		mi.mesh = mesh
		mi.material_override = preload("res://Assets/Materials/dreamcore.tres")
		#_create_block_collider(block_position)
		add_child.call_deferred(mi)


#func _create_block_collider(block_sub_position: Vector3) -> void:
	#var collider := CollisionShape3D.new()
	#collider.shape = BoxShape3D.new()
	#collider.shape.extents = Vector3.ONE / 2
	#collider.transform.origin = Vector3(block_sub_position) + Vector3.ONE / 2
	#add_child(collider)


static func is_block_transparent(block_id: int) -> int:
	return block_id == 0 or (block_id > 25 and block_id < 30)
