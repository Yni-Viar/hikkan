## Auto-loaded node that loads and gives access to all [Background] resources in the game.
extends Node

const NARRATOR_ID := "narrator"

var _characters: Dictionary
var _backgrounds: Dictionary

func _ready() -> void:
	var vn_res_db: VNResDB = load("res://addons/godot-visual-novel/Autoloads/VNResDB.tres")
	_characters = vn_res_db.characters
	_backgrounds = vn_res_db.backgrounds

func get_character(character_id: String) -> Character:
	return _characters.get(character_id)


func get_narrator() -> Character:
	return _characters.get(NARRATOR_ID)


func get_background(background_id: String) -> Background:
	return _backgrounds.get(background_id)


## Finds and loads resources of a given type in `directory_path`.
## As we don't have generics in GDScript, we pass a function's name to do type checks.
## We call that function on each loaded resource with `call()`.
func _load_resources(directory_path: String, check_type_function: String) -> Dictionary:
	var directory := DirAccess.open(directory_path)
	if not directory:
		return {}

	var resources := {}

	directory.list_dir_begin() # TODOConverter3To4 fill missing arguments https://github.com/godotengine/godot/pull/40547
	var filename = directory.get_next()
	while filename != "":
		print(filename)
		if ResourceLoader.exists(directory_path.path_join(filename)):
			var resource: Resource = load(directory_path.path_join(filename))
			if not call(check_type_function, resource):
				filename = directory.get_next()
				continue

			resources[resource.id] = resource
			
		filename = directory.get_next()
	directory.list_dir_end()

	return resources


func _is_character(resource: Resource) -> bool:
	return resource is Character


func _is_background(resource: Resource) -> bool:
	return resource is Background
