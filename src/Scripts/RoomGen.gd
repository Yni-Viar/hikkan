extends StaticBody3D
## Living room generator
## Made by Yni, licensed under MIT License.

var rng: RandomNumberGenerator

var spawned_index: Dictionary[String, PackedInt32Array] = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rng = get_tree().root.get_node("Game").rng
	spawner(2, "res://Assets/OriginalAssets/closet.tscn", "closet", "NavigationRegion3D/ClosetSpawns")
	spawner(1, "res://Assets/HomeGenerator/Clutter/sofa_table_clutter.tscn", "sofa_with_table", "NavigationRegion3D/SofaWithTableSpawns")
	spawner(1, "res://Assets/HomeGenerator/Clutter/cloth.tscn", "clothes", "ClothesSpawns")
	
	if get_tree().get_node_count_in_group("SofaSpawn") > 0:
		for i in range(get_tree().get_node_count_in_group("SofaSpawn")):
			if i == 0:
				var sofa: Node3D = load("res://Assets/ThirdPartyAssets/Sofa.tscn").instantiate()
				get_tree().get_nodes_in_group("SofaSpawn")[0].add_child(sofa)
			else:
				# clutter_s_t means clutter sofa/trable
				var clutter_s_t: Node3D = load("res://Assets/ThirdPartyAssets/dresser_1.tscn").instantiate()
				get_tree().get_nodes_in_group("SofaSpawn")[i].add_child(clutter_s_t)
	
	if get_tree().get_node_count_in_group("LaptopSpawn") > 0:
		for i in range(get_tree().get_node_count_in_group("LaptopSpawn")):
			if i % 2 == 0:
				var laptop: Node3D = load("res://Assets/ThirdPartyAssets/Laptop.tscn").instantiate()
				get_tree().get_nodes_in_group("LaptopSpawn")[i].add_child(laptop)
	
	$NavigationRegion3D.bake_navigation_mesh()
	
# BEGIN code from Godot Docs
	# 3D margins are designed to work with 3D world unit values.
	var default_map_rid: RID = get_world_3d().get_navigation_map()
	NavigationServer3D.map_set_edge_connection_margin(default_map_rid, 1.675)
# END code from Godot Docs

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func spawner(amount: int, asset_path: String, spawnable_name: String, spawning_path: NodePath):
	for i in range(amount):
		var asset: Node3D = load(asset_path).instantiate()
		var spawner_count = get_node(spawning_path).get_child_count()
		if !spawned_index.has(spawnable_name):
			spawned_index[spawnable_name] = PackedInt32Array()
		if spawned_index[spawnable_name].size() < spawner_count:
			for j in range(spawner_count * 2):
				var random_number = rng.randi_range(0, spawner_count - 1)
				if spawned_index[spawnable_name].has(random_number):
					continue
				get_node(spawning_path).get_child(random_number).add_child(asset)
				spawned_index[spawnable_name].append(random_number)
				break
		else:
			break
