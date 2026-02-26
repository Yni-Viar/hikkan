extends Control
## Main Menu
## Made by Yni, licensed under MIT license.

# Called when the node enters the scene tree for the first time.
func _enter_tree() -> void:
	# Display game ratings in main menu in some countries, this will replace the game logo.
	if Settings.legal_req:
		match Settings.region:
			"ru_RU":
				# New upcoming Russian law.
				$LawRegulation.texture = load("res://UI/MainMenu/LawRegulation/RU.png")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_play_pressed() -> void:
	play()


func _on_credits_pressed() -> void:
	$CreditsContainer.visible = true


func play():
	Settings.loader("res://Scenes/Game.tscn", {
		"map_seed": hash($Seed.text) if !$Seed.text.is_empty() else -1,
	})
	
	#$FakeLoadingScreen.show()
	#
	#var game: GameCore = load("res://Scenes/Game.tscn").instantiate()
	#if !$GameSettings/Seed.text.is_empty():
		#game.map_seed = hash($GameSettings/Seed.text)
	#game.time_limited = $GameSettings/TimeLimited.button_pressed
	#get_tree().root.add_child(game)
	#Settings.call_deferred("override_main_scene", game)
	#queue_free()

func _on_settings_pressed() -> void:
	$Settings.show()


func _on_back_button_pressed() -> void:
	$CreditsContainer.visible = false
