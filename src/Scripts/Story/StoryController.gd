extends Node
## In-game story
## Made by Yni, licensed under MIT License.

var door: Node3D

# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#pass
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass

## The main story triggers, the other one are in Laptop and ExitDoor scripts
func _on_game_day_changed() -> void:
	match get_tree().root.get_node("Game").current_day:
		1:
			start_cutscene(0)
		3:
			door = get_tree().get_first_node_in_group("Door")
			if door == null:
				return
			if door.get_node_or_null("DoorSound") != null:
				door.get_node("DoorSound").play()
			if door.get_node_or_null("Blip") != null:
				door.get_node("Blip").show()
				door.get_node("Blip").play("blip")
		4:
			if door == null:
				return
			if door.get_node_or_null("Blip") != null:
				door.get_node("Blip").hide()
				door.get_node("Blip").play("default")
		5:
			var fate: Dictionary = Variables.get_stored_variables_list()
			if fate.has("day_4_good"):
				if fate["day_4_good"] == true:
					start_cutscene(4)
					get_tree().root.get_node("Game").finish_game("GOOD ENDING", "You overwhelmed your fear and went to walk.\nYou've done it!")
				else:
					await get_tree().create_timer(5.0).timeout
					get_tree().root.get_node("Game/Player").movement_freeze = true
					get_tree().root.get_node("Game/Player/PlayerModel").get_child(0).set_anim_state("Idle_No_Loop_retargeted", true)
					await get_tree().create_timer(3.0).timeout
					get_tree().root.get_node("Game").finish_game("BAD ENDING", "You continued to live as hikkikomori...\nYou ignored a hand, that wanted to help you to get out...")
			else:
				await get_tree().create_timer(5.0).timeout
				get_tree().root.get_node("Game/Player").movement_freeze = true
				get_tree().root.get_node("Game/Player/PlayerModel").get_child(0).set_anim_state("Idle_No_Loop_retargeted", true)
				await get_tree().create_timer(3.0).timeout
				get_tree().root.get_node("Game").finish_game("BAD ENDING", "You continued to live as hikkikomori...\nYou did not even try to take a helping hand...")
			Variables.clear()

func start_cutscene(key: int):
	get_tree().root.get_node("Game/Player").movement_freeze = true
	get_tree().root.get_node("Game/UI/VN").play_scene(key)


func _on_vn_finished() -> void:
	get_tree().root.get_node("Game/Player").movement_freeze = false
