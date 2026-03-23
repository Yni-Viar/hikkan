extends Control
## Made by Yni, licensed under MIT License

var input_amount: Dictionary[int, Vector2] = {}
var dragged: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_playing_area_gui_input(event: InputEvent) -> void:
	if Settings.touchscreen:
# BEGIN https://github.com/godotengine/godot-demo-projects/blob/master/mobile/multitouch_cubes/GestureArea.gd
# Copyright (c) 2014-present Godot Engine contributors.
# Copyright (c) 2007-2014 Juan Linietsky, Ariel Manzur.
# Licensed under MIT license
		var finger_count := input_amount.size()

		if finger_count == 0:
			# No fingers => Accept press.
			if event is InputEventScreenTouch:
				if event.pressed:
					# A finger started touching.

					input_amount[event.index] = event.position

		elif finger_count == 1:
			# One finger => For rotating around X and Y.
			# Accept one more press, unpress or drag.
			if event is InputEventScreenTouch:
				if input_amount.has(event.index):
					# Only touching finger released.
# END https://github.com/godotengine/godot-demo-projects/blob/master/mobile/multitouch_cubes/GestureArea.gd
					if dragged:
						dragged = false
					else:
						get_tree().root.get_node("Game/StaticPlayer").interact("Point")
# BEGIN https://github.com/godotengine/godot-demo-projects/blob/master/mobile/multitouch_cubes/GestureArea.gd
# Copyright (c) 2014-present Godot Engine contributors.
# Copyright (c) 2007-2014 Juan Linietsky, Ariel Manzur.
# Licensed under MIT license
					input_amount.clear()

			elif event is InputEventScreenDrag:
				if input_amount.has(event.index):
					# Touching finger dragged.
# END https://github.com/godotengine/godot-demo-projects/blob/master/mobile/multitouch_cubes/GestureArea.gd
					dragged = true
					get_tree().root.get_node("Game/StaticPlayer").rotate_player(event)
	elif Input.is_action_pressed("click"):
		get_tree().root.get_node("Game/StaticPlayer").interact("Point")
		Input.action_release("click")

## Toggles filter between Mouse filter Stop and Ignore.
## Useful for cutscenes
func _toggle_mouse_filter(stop: bool):
	if stop:
		mouse_filter = MouseFilter.MOUSE_FILTER_STOP
	else:
		mouse_filter = MouseFilter.MOUSE_FILTER_IGNORE


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if get_tree().root.get_node_or_null("Game/Player") != null:
		get_tree().root.get_node("Game/Player").movement_freeze = false


func _on_back_button_pressed() -> void:
	Settings.loader("res://Scenes/Menu.tscn", {})
