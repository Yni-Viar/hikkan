extends InteractableStatic
## Made by Yni, licensed under MIT License.

var phrases: PackedStringArray = [
	"It was tasty.",
	"It was an usual breakfast."
]

## Eat your breakfast
func interact(player: Node3D):
	super.interact(player)
	player.set_target_position(self.global_position)
	await get_tree().create_timer(1.0).timeout
	if player.current_health[0] < 100:
		# Eat your breakfast
		get_tree().root.get_node("Game").action("You decided to eat breakfast. " + phrases[get_tree().root.get_node("Game").rng.randi_range(0, phrases.size() - 1)], 0)
		player.health_manage(100)
