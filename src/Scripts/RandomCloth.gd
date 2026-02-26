extends SoftBody3D
## Random cloths generator.
## Used to create a mess in the house.
## Made by Yni, licensed under MIT License.

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_surface_override_material(0, load("res://Assets/Materials/fabric" + str(rng.randi_range(1, 4))+ ".tres"))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
