extends InteractableStatic
## Made by Yni, licensed under MIT License.

# This variable prevent second attempt to interact
var story_day_2_finished: bool = false

## Time warper
func interact(player: Node3D):
	super.interact(player)
	player.set_target_position(self.global_position)
	await get_tree().create_timer(1.0).timeout
	
	#Day2 quest
	if get_tree().root.get_node("Game").current_day == 2 && !story_day_2_finished:
		get_tree().root.get_node("Game/StoryController").start_cutscene(1)
		story_day_2_finished = true
	else:
		get_tree().root.get_node("Game").plan_task("Do you want to go online?", "You spent your time sitting online.")
