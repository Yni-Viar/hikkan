extends BasePuppetScript
## Example implementation of human system.
## Made by Yni, licensed under MIT license.
class_name HumanPuppetScript

var has_animtree: bool = false

func _ready() -> void:
	if get_node_or_null("AnimationTree") != null:
		has_animtree = true
		get_node("AnimationTree").active = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	# Change animation state
	if has_animtree:
		match state:
			States.IDLE:
				if !get_node("AnimationTree").get("parameters/state_machine/blend_amount") - 0.00001 < 0.0:
					call("set_state", "state_machine", "blend_amount", lerp(get_node("AnimationTree").get("parameters/state_machine/blend_amount"), 0.0, get_parent().get_parent().character_speed * delta))
			States.WALKING:
				if !get_node("AnimationTree").get("parameters/state_machine/blend_amount") + 0.00001 > 1.0:
					call("set_state", "state_machine", "blend_amount", lerp(get_node("AnimationTree").get("parameters/state_machine/blend_amount"), 1.0, get_parent().get_parent().character_speed * delta))
					call("set_state", "walk_speed", "scale", get_parent().get_parent().character_speed / 2)
			#States.RUNNING:
				#if !get_node("AnimationTree").get("parameters/state_machine/blend_amount") + 0.00001 > 1:
					#call("set_state", "state_machine", "blend_amount", lerp(get_node("AnimationTree").get("parameters/state_machine/blend_amount"), 1.0, get_parent().get_parent().character_speed * delta))

## Set animation to an entity via Animation Tree.
func set_state(animation_name: String, action_name: String, amount):
	get_node("AnimationTree").set("parameters/" + animation_name + "/" + action_name, amount)

## Set single animation, without AnimationTree
func set_anim_state(animation_name: String, stop_anim_tree: bool = false):
	if has_animtree:
		get_node("AnimationTree").active = !stop_anim_tree
	if $AnimationPlayer.current_animation != animation_name:
		$AnimationPlayer.play(animation_name)

## Playing footsteps
#func footstep(key: String):
	#get_parent().get_parent().get_node("WalkSounds").stream = load(get_parent().get_parent().puppet_class.footstep_sounds[key][rng.randi_range(0, get_parent().get_parent().puppet_class.footstep_sounds[key].size() - 1)])
	#get_parent().get_parent().get_node("WalkSounds").play()
