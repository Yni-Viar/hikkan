extends Node
## Made by Yni, licensed under MIT License.

## Stages of the developing
enum Stages {release, testing, dev}
enum ItemType {item, map_object, npc}
enum Season {NONE, WINTER, SPRING, SUMMER, AUTUMN, CHRISTMAS, HALLOWEEN}

signal settings_saved

## Migrated from Globals.
## Game's data compatibility for modding.
const DATA_COMPATIBILITY: String = "0.1.0"
## Migrated from Globals.
## Game's data compatibility for modding.
const CURRENT_STAGE: Stages = Stages.dev
## If we don't specify regions, which have additional legal requirements, we are in trouble.
const LEGAL_REQ_REGIONS: Dictionary[String, PackedStringArray] = {
	"ru_RU": ["generic_ru"]
}
## Touchscreen check
var touchscreen: bool = false
## Settings resource
var setting_res: SettingsResource

var paused_game = false
## If we don't specify regions, which have additional legal requirements, we are in trouble.
var region: String = "":
	set(val):
		region = val
		legal_req = is_legal_req()
var legal_req: bool = false
var current_season: Season = Season.NONE

var dreamcore_render_distance: int = 7

func _init():
	load_resource()
	audio_settings(1, setting_res.music_volume)
	# Set the region (needed for obeying contries' laws)
	region = OS.get_locale()

func _ready() -> void:
	touchscreen = DisplayServer.is_touchscreen_available()
	season_checker()

## Sometimes ago it was a great function. Now it is just a stub, that calls ResourceStorage and loads settings
func load_resource():
	if OS.get_name() != "Web":
		var settings_from_file = ResourceStorage.load_resource("user://Settings.bin", "SettingsResource")
		if settings_from_file != null:
			setting_res = settings_from_file
			set_default_keybinds()
		else:
			load_default_settings()
	else:
		load_default_settings()
		set_default_keybinds()

func load_default_settings():
	if OS.get_name() != "Web" && OS.get_name() != "Android":
		var res = load("res://Scripts/SettingsResource/Presets/OpenGL/Low.tres")
		save_resource(res)
		setting_res = res
	else:
		var res = load("res://Scripts/SettingsResource/Presets/OpenGL/Lowest.tres")
		save_resource(res)
		setting_res = res
	set_default_keybinds()

## Sometimes ago it was a great function. Now it is just a stub, that calls ResourceStorage and saves settings
func save_resource(res):
	if OS.get_name() != "Web":
		ResourceStorage.save_resource("user://Settings.bin", res)
		emit_signal("settings_saved")

func season_checker():
	match Time.get_datetime_dict_from_system()["month"]:
		1:
			if Time.get_datetime_dict_from_system()["day"] <= 3:
				current_season = Season.CHRISTMAS
			else:
				current_season = Season.WINTER
		2:
			current_season = Season.WINTER
		3, 4, 5:
			current_season = Season.SPRING
		6, 7, 8:
			current_season = Season.SUMMER
		9, 11: # this was NOT intended!!!
			current_season = Season.AUTUMN
		10:
			if !feature_legality_checker("no_halloween"):
				current_season = Season.HALLOWEEN
			else:
				current_season = Season.AUTUMN
		12:
			current_season = Season.CHRISTMAS
		_:
			print("Date not available")
			current_season = Season.NONE

func is_legal_req() -> bool:
	return LEGAL_REQ_REGIONS.has(region)

func feature_legality_checker(feature: String) -> bool:
	return LEGAL_REQ_REGIONS[region].has(feature)

func audio_settings(bus: int, val: float):
	AudioServer.set_bus_volume_db(bus, linear_to_db(val))
	if val < 0.01:
		AudioServer.set_bus_mute(bus, true)
	elif val >= 0.01 && AudioServer.is_bus_mute(bus):
		AudioServer.set_bus_mute(bus, false)	

func override_main_scene(scene: Node):
	get_tree().current_scene = scene

func set_default_keybinds():
	for value in setting_res.keybinds.keys():
		set_keybind(value, setting_res.keybinds[value][0], setting_res.keybinds[value][1])

func set_keybind(action_name: String, key_type: int, key: int):
	InputMap.action_erase_events(action_name)
	match key_type:
		0:
			var event: InputEventKey = InputEventKey.new()
			event.physical_keycode = key as Key
			InputMap.action_add_event(action_name, event)
		1:
			var event: InputEventMouseButton = InputEventMouseButton.new()
			event.button_index = key as MouseButton
			InputMap.action_add_event(action_name, event)
		2:
			print("Gamepad support is not implemented.")
	setting_res.keybinds[action_name] = [key_type, key]
	save_resource(setting_res)

## Current season check
func season_feature_checker(season_check: Season) -> bool:
	if current_season == season_check || \
	 season_check == Season.NONE && current_season <= 4:
		return true
	else:
		return false

func loader(file_path_to_load: String, parameters: Dictionary[String, Variant]):
	if get_child_count() > 0:
		if get_child(0) is LoadingScreen:
			return
	var loading_screen: LoadingScreen = load("res://Scenes/LoadingScreen.tscn").instantiate()
	loading_screen.file_path_to_load = file_path_to_load
	loading_screen.parameters = parameters
	
	add_child(loading_screen)
