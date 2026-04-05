extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$WorldEnvironment.environment.ssao_enabled = Settings.setting_res.ssao
	$WorldEnvironment.environment.tonemap_mode = Settings.setting_res.tonemapper
	if Settings.setting_res.tonemapper != Environment.TONE_MAPPER_LINEAR || \
	 Settings.setting_res.tonemapper != Environment.TONE_MAPPER_AGX:
		$WorldEnvironment.environment.tonemap_white = 2.0
	else:
		$WorldEnvironment.environment.tonemap_white = 1.0
	$UI/VN.play_scene(0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

## Game end
func finish_game(ending_label: String, reason: String):
	if get_node_or_null("Player") != null:
		$Player.movement_freeze = true
	$UI/AfterEnd/Title.text = ending_label
	$UI/AfterEnd/Reason.text = reason
	$UI/AnimationPlayer.play("transition_ending")
