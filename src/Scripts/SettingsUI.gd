extends VBoxContainer
## Made by Yni, licensed under MIT License.

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Glow.button_pressed = Settings.setting_res.glow
	$BasicReflection.button_pressed = Settings.setting_res.reflection_probe
	$SSAO.button_pressed = Settings.setting_res.ssao
	$Music/MusicVolume.value = Settings.setting_res.music_volume


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_music_volume_drag_ended(value_changed: bool) -> void:
	if value_changed:
		Settings.audio_settings(1, $Music/MusicVolume.value)
		Settings.setting_res.music_volume = $Music/MusicVolume.value
		Settings.save_resource(Settings.setting_res)

func _on_basic_reflection_toggled(toggled_on: bool) -> void:
	Settings.setting_res.reflection_probe = toggled_on
	Settings.save_resource(Settings.setting_res)

func _on_glow_toggled(toggled_on: bool) -> void:
	Settings.setting_res.glow = toggled_on
	Settings.save_resource(Settings.setting_res)

func _on_ssao_toggled(toggled_on: bool) -> void:
	Settings.setting_res.ssao = toggled_on
	Settings.save_resource(Settings.setting_res)
