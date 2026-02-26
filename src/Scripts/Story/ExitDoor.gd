extends InteractableStatic
## Made by Yni, licensed under MIT License.

# These two variables prevent second attempt to interact
var knock_opened: bool = false
var day_4_go_out: bool = false

## Different reactions, based on in-game day.
func interact(player: Node3D):
	super.interact(player)
	match get_tree().root.get_node("Game").current_day:
		1:
			get_tree().root.get_node("Game").action("You tried to open you door, but you... could not do it.", 0)
		2:
			get_tree().root.get_node("Game").action("You tried to open you door, but you... could not do it (as for now).", 0)
		3:
			if !knock_opened:
				get_tree().root.get_node("Game/StoryController").start_cutscene(2)
				get_parent().get_parent().get_node("Blip").hide()
				get_parent().get_parent().get_node("Blip").play("default")
		4:
			if !day_4_go_out:
				if get_tree().root.get_node("Game").rng.randi_range(0, 32) == 13:
					Settings.loader("res://Scenes/Dreamcore.tscn", {})
				else:
					get_tree().root.get_node("Game/StoryController").start_cutscene(3)
				day_4_go_out = true
