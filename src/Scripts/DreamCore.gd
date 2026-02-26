extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
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
