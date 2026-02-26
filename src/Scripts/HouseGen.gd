extends Node3D
## House map generator
## Made by Yni, licensed under MIT License
class_name HouseGenerator

signal generated

@export var rooms: HouseGenZone
@export var size: int = 2
## Prints map seed
@export var debug_print: bool = false
@export var grid_size: float = 4.55
@export var end_door_size: Vector2 = Vector2(4.7, 4.65)
@export var end_door_x_offset: float = 0.035

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

## House generator
## The house is based on straight line with rooms, which can be rotated by 180 degrees.
func generate() -> void:
	clear()
	if rooms == null:
		if debug_print:
			printerr("No rooms are set. Create a resource, please...")
		return
	if debug_print:
		print("Generating house...")
	var selected_room: PackedScene
	var room: Node3D
	for i in range(size):
		if i >= rooms.rooms_single.size():
			selected_room = rooms.rooms[rng.randi_range(0, rooms.rooms.size() - 1)]
		else:
			selected_room = rooms.rooms_single[i]
		room = selected_room.instantiate()
		room.position = Vector3(i * grid_size, 0, 0)
		room.rotation_degrees = Vector3(0, 270.0 if rng.randi_range(0, 1) == 1 else 90.0, 0)
		add_child(room, true)
	spawn_doors()
	generated.emit()

## Spawn doors
func spawn_doors() -> void:
	if debug_print:
		print("Spawning doors...")
	var startup_node: Node = Node.new()
	startup_node.name = "DoorFrames"
	add_child(startup_node)
	var door: Node3D
	for i in range(size - 1):
		if rooms.door_frames.size() > 0:
			door = rooms.door_frames[rng.randi_range(0, rooms.door_frames.size() - 1)].instantiate()
			door.position = global_position + Vector3(i * grid_size + grid_size / 2, 0, 0)
			door.rotation_degrees = Vector3(0, 90, 0)
			startup_node.add_child(door)
	var end_door = generate_end_door(true)
	door = Node3D.new()
	door.add_child(end_door)
	door.position = global_position + Vector3((size - 1) * grid_size + grid_size / 2, 0, 0)
	door.rotation_degrees = Vector3(0, 90, 0)
	startup_node.add_child(door)
	end_door = generate_end_door(false)
	door = Node3D.new()
	door.add_child(end_door)
	door.position = global_position - Vector3(grid_size / 2, 0, 0)
	door.rotation_degrees = Vector3(0, 90, 0)
	startup_node.add_child(door)

## Generate end door mesh
func generate_end_door(flip_faces: bool) -> MeshInstance3D:
	var end_door: MeshInstance3D = MeshInstance3D.new()
	end_door.mesh = QuadMesh.new()
	end_door.mesh.size = end_door_size
	end_door.mesh.center_offset = Vector3(end_door_x_offset, end_door_size.y / 2, 0)
	end_door.mesh.flip_faces = flip_faces
	end_door.mesh.material = rooms.end_door_material
	end_door.create_trimesh_collision()
	return end_door

func clear():
	for node in get_children():
		node.queue_free()
