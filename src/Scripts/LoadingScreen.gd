extends Control
## Made by Yni, licensed under MIT license.
class_name LoadingScreen

@export var file_path_to_load: String
@export var parameters: Dictionary[String, Variant] = {}


var loading: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if file_path_to_load.contains("res://"):
		await get_tree().create_timer(0.375).timeout
		var old_scene = get_tree().current_scene
		old_scene.queue_free()
		ResourceLoader.load_threaded_request(file_path_to_load, "", false, ResourceLoader.CACHE_MODE_IGNORE_DEEP)
		loading = true
		show()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if loading:
		var progress: Array
		var status = ResourceLoader.load_threaded_get_status(file_path_to_load, progress)
		match status:
			ResourceLoader.THREAD_LOAD_FAILED, ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
				# Need to port message system from InE Demo 2
				get_tree().quit(1)
			ResourceLoader.THREAD_LOAD_IN_PROGRESS:
				$LoadProgress.value = progress[0] * 100
			ResourceLoader.THREAD_LOAD_LOADED:
				$LoadProgress.value = 100
				loading = false
				var game: Node = ResourceLoader.load_threaded_get(file_path_to_load).instantiate()
				for parameter in parameters:
					game.set(parameter, parameters[parameter])
				get_tree().root.add_child(game, true)
				call_deferred("load_complete", game)

func load_complete(scene: Node):
	Settings.override_main_scene(scene)
	queue_free()
