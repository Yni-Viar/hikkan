extends Node3D
## Made by Yni, licensed under MIT License

signal day_changed

var map_seed: int = -1

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
## Current game. There are 5 days.
var current_day = 1
## Current hours
var hours: int = 7
## Current minutes
var minutes: int = 0

var _choice_action: String = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	RenderingServer.viewport_set_measure_render_time(get_tree().root.get_viewport_rid(), true)
	if map_seed != -1:
		rng.seed = map_seed
	
	$WorldEnvironment.environment.glow_enabled = Settings.setting_res.glow
	$WorldEnvironment.environment.ssao_enabled = Settings.setting_res.ssao
	
	$HouseGenerator.rng = rng
	$HouseGenerator.size = rng.randi_range(2, 3)
	$HouseGenerator.generate()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if $DirectionalLight3D.rotation_degrees.y > -90.0 || hours < 16:
		$DirectionalLight3D.rotate_y(-(PI / 180) * delta)
		# In this game, Sun goes from 9:00 to 15:00
		# 4.0 is spare time, because one time rotation goes below zero
		# 
		var time_left = 4.0 + ($DirectionalLight3D.rotation_degrees.y / 15.0) / 2
		# 18 - time_left is hour amount
		hours = 15 - int(time_left)
		# We want first two decimal values and divide them by 60 to get minutes and multiplying by 100 for int conversion.
		minutes = int((ceil(time_left) - time_left) * 60) 
		$UI/CurrentTime.text = "Current time: " + str(hours).lpad(2, "0") + ":" + str(minutes).lpad(2, "0")
	else:
		# Next day
		hours = 15
		minutes = 0
		$UI/CurrentTime.text = "Current time: " + str(hours) + ":" + str(minutes).lpad(2, "0")
		set_physics_process(false)
		day_after_day()

## Game end
func finish_game(ending_label: String, reason: String):
	if get_node_or_null("Player") != null:
		$Player.movement_freeze = true
	$UI/AfterEnd/Title.text = ending_label
	$UI/AfterEnd/Reason.text = reason
	$UI/AnimationPlayer.play("transition_ending")

## Long action. Use while working at PC, eating and inactive door triggers
func action(text: String, result_hours: int):
	$UI/BackButton.show()
	$Player.movement_freeze = true
	$UI/AnimationPlayer.play("transition_action")
	$UI/Action/ActionLabel.text = text
	hours += result_hours
	$DirectionalLight3D.rotation_degrees.y = float((15 - hours - 4) * 2 * 15)

## Day changer
func day_after_day():
	$Player.movement_freeze = true
	current_day += 1
	if current_day < 5:
		$UI/AnimationPlayer.play("transition_action")
		$UI/Action/ActionLabel.text = "You spent your evening sitting online and slept a night.\n\
		Day come after day, could you overwhelm your fear?"
	
	hours = 9
	minutes = 0
	$Player.global_position = get_tree().get_nodes_in_group("PlayerSpawn")[rng.randi_range(0, get_tree().get_node_count_in_group("PlayerSpawn") - 1)].global_position
	$Player.health_manage(-20)
	
	await get_tree().process_frame
	$DirectionalLight3D.rotation_degrees.y = 90.0
	if get_node_or_null("Player") != null:
		$UI/Day.text = "DAY " + str(current_day)
		var tween = get_tree().create_tween()
		tween.tween_property($UI/Day, "position", Vector2(192.0, 64.0), 1.0)
		tween.tween_property($UI/Day, "position", Vector2(192.0, 64.0), 4.0)
		tween.tween_property($UI/Day, "position", Vector2(192.0, -192.0), 2.0)
		day_changed.emit()
		set_physics_process(true)

## Used only with PC.
func plan_task(choice_name: String, consequence_text: String):
	$UI/BackButton.hide()
	$Player.movement_freeze = true
	$UI/AnimationPlayer.play("transition_choice")
	$UI/Choice/ChoiceLabel.text = choice_name
	_choice_action = consequence_text

func _on_house_generator_generated() -> void:
	$Player.global_position = get_tree().get_nodes_in_group("PlayerSpawn")[rng.randi_range(0, get_tree().get_node_count_in_group("PlayerSpawn") - 1)].global_position
	
	## Enable/disable reflection probes (cubemap)
	for node in get_tree().get_nodes_in_group("ReflectionProbe"):
		if node is ReflectionProbe:
			if !Settings.setting_res.reflection_probe: # || Settings.setting_res.ssr:
				node.hide()
			else:
				node.show()
	
	day_changed.emit()
	$UI/Day.text = "DAY " + str(current_day)
	var tween = get_tree().create_tween()
	tween.tween_property($UI/Day, "position", Vector2(192.0, 64.0), 1.0)
	tween.tween_property($UI/Day, "position", Vector2(192.0, 64.0), 4.0)
	tween.tween_property($UI/Day, "position", Vector2(192.0, -192.0), 2.0)

func _on_confirm_pressed() -> void:
	$UI/Choice.hide()
	action(_choice_action, int($UI/Choice/Hour.value))
