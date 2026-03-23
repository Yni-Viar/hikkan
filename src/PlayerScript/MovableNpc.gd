extends CharacterBody3D
class_name MovableNpc
## Mostly made by Yni, licensed under MIT license.
## ------------------------------------------
## Contains third-party code from Godot demos. 
## Copyright (c) 2014-present Godot Engine contributors.
## Copyright (c) 2007-2014 Juan Linietsky, Ariel Manzur.
## Licensed under MIT License.
## ------------------------------------------
## Interactable NPC. Best optimized for Humanizer - Makehuman addon for Godot.

## State machine
#enum State {
	#IDLE,
	#WALKING,
	#RUNNING
#}
## Speed
@export var character_speed: float = 4.5
## Path to the skeleton. Used for LookAt IK function.
#@export var skeleton_path: NodePath
## Can the character speak
#@export var can_talk: bool = false

## Move sounds toggle
@export var move_sounds_enabled: bool = false
## Walk sounds
@export var footstep_sounds: Array[String]
## Sprint sounds
@export var sprint_sounds: Array[String]

## Dialogues.
## The structure of the array:
## [[path_to_the_dialogue, dialogue_name], ...]
## E.g. [["res://Dialogues/dlg_test.tres", "dlg_test"]]
#@export var dialogues: Array[Array]
## State machine
#@export var state: State = State.IDLE
## Applies height bugfix
@export var apply_height_bugfix: bool = false
## How much the height of character will be decreased
@export var height_bugfix_amount: float = -0.04
## Is the character on moving platform (a workaround, since without this the NPC flies away)
## Alias for movement_freeze, use this only in elevators
@export var platform_moving: bool = false
## Is a player-controlled pawn
@export var is_player: bool = false
## Freeze the player or not
@export var movement_freeze: bool = false

@export var health: Array[float] = []
@export var current_health: Array[float] = []

## The main wandering switch
@export var wandering: bool = false:
	set(val):
		if val:
			idle = true
		else:
			idle = false
		wandering = val

## How many npc will rotate
var wandering_rotator: int
## Walking/rotating toggle
var wander_action: bool = false
## On which degree npc will wander
var wandering_destination: int
## Only when idle NPC will wander
var idle: bool = false
## Only when ready, NPC can wander
var wandering_ready: bool = false

## Just for optimization purposes
## E.g. wandering will be disabled, if npc is not visible
var visible_on_screen: bool = false

## Current dialogue
var current_dialogue: int = 0
## Interval between re-calling target follow (only when they follow)
var follow_update_timer: float = 1.0
## Follow target. If is valid path (BEGINNING WITH /root/ !), they will look at target and follow.
var follow_target: String = ""#:
	#set(val):
		#if !val.is_empty(): 
			#if get_node_or_null(val) != null:
				## New Godot 4.4 feature - the NPC will actually look at player when following them.
				#get_node(str(skeleton_path) + "/LookAtModifier3D").target_node = NodePath(val + "/LookAtTarget")
			#else:
				#get_node(str(skeleton_path) + "/LookAtModifier3D").target_node = ""
		#else:
			#get_node(str(skeleton_path) + "/LookAtModifier3D").target_node = ""
		#follow_target = val
## A workaround, where NPC cannot cross by NavigationLink, when something with navigation will move.
var prev_offset: PackedVector3Array = [Vector3.ONE, Vector3.ONE]
## A check for bugfix height only once.
var height_bugfix_applied: bool = false
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var puppet_mesh: BasePuppetScript

@onready var walk_sounds = $WalkSounds
# Begin Godot Demo code (MIT License)
#@onready var anim = $AnimationTree as AnimationTree
@onready var _nav_agent := $NavigationAgent3D as NavigationAgent3D

func _ready() -> void:
	#if anim != null:
		#anim.active = false
		#anim.advance_expression_base_node = get_path()
		#anim.active = true
	#state = State.IDLE
	if get_node("PlayerModel").get_child_count() > 0:
		puppet_mesh = get_node("PlayerModel").get_child(0)
	wandering_rotator = rng.randi_range(-15, 15)
	NavigationServer3D.map_changed.connect(on_map_updated)

func _physics_process(delta: float) -> void:
	#if anim != null:
		#animation_state_machine(delta)
	# Wander if wandering enabled
	if wandering && idle && visible_on_screen:
		wander(delta)
	# Stop when platform is moving
	if platform_moving || movement_freeze:
		if puppet_mesh != null:
			puppet_mesh.state = puppet_mesh.States.IDLE
		#state = State.IDLE
		if !is_on_floor():
			velocity += get_gravity() * delta
		move_and_slide()
		return
	# Follow the target, if target is not empty.
	if !follow_target.is_empty():
		if get_node_or_null(follow_target) != null:
			target_follow()
	
	if _nav_agent.is_navigation_finished():
		if puppet_mesh != null:
			if puppet_mesh.state != puppet_mesh.States.IDLE:
				# Strange bug fix (where NPC was always had standing animation (even when moving))
				if global_position.distance_to(_nav_agent.get_final_position()) <= 1:
					puppet_mesh.state = puppet_mesh.States.IDLE
				if wandering:
					idle = true
		return
	
		
	
	var next_position := _nav_agent.get_next_path_position()
	var offset := next_position - global_position
	if stop_check(offset):
		if puppet_mesh != null:
			if character_speed > 15:
				puppet_mesh.state = puppet_mesh.States.RUNNING
			else:
				puppet_mesh.state = puppet_mesh.States.WALKING
		global_position = global_position.move_toward(next_position, delta * character_speed)
		look_at(global_position + Vector3(offset.x, 0, offset.z), Vector3.UP)
	elif puppet_mesh != null:
		puppet_mesh.state = puppet_mesh.States.IDLE
	move_and_slide()
	prev_offset[1] = prev_offset[0]
	prev_offset[0] = offset

## (Almost) precise check - is player actually moved
func stop_check(offset: Vector3) -> bool:
	var check: Vector3 = Vector3.ZERO
	for prev in prev_offset:
		check += prev
	check /= prev_offset.size()
	if offset.distance_squared_to(check) < 0.001:
		return false
	else:
		return true

func set_target_position(target_position: Vector3, hold: bool = false) -> void:
	if movement_freeze:
		return
	
	_nav_agent.set_target_position(target_position)
	# Change state
	if puppet_mesh != null:
		if character_speed > 15:
			puppet_mesh.state = puppet_mesh.States.RUNNING
		else:
			puppet_mesh.state = puppet_mesh.States.WALKING
	
	#if character_speed > 10:
		#state = State.RUNNING
	#else:
		#state = State.WALKING
	idle = false
	if apply_height_bugfix && !height_bugfix_applied:
		$Armature.position.y = height_bugfix_amount
	if hold:
		hold_still()

# End Godot Demo code (MIT License)

## Health management (health type: 0 is generic health)
func health_manage(health_to_add: float, health_type: int = 0):
	if health_type >= current_health.size() || health_type >= health.size():
		print("Invalid parameter - wrong health type")
	if current_health[health_type] + health_to_add <= health[health_type]:
		current_health[health_type] += health_to_add
	else:
		current_health[health_type] = health[health_type]
	if health_type == 1:
		if current_health[1] < health[1]:
			$StatusEffects.apply_status_effect("Frozen", (health[1] - current_health[1]) / health[1], 0.0)
		else:
			$StatusEffects.apply_status_effect("Frozen", 0.0, 0.0)
	
	if current_health[health_type] <= 0:
		# Remove one live
		queue_free()

#func animation_state_machine(delta: float):
	#match state:
		#State.IDLE:
			#if anim["parameters/state_machine/blend_amount"] - 0.001 >= -1:
				#anim["parameters/state_machine/blend_amount"] = move_toward(anim["parameters/state_machine/blend_amount"], -1, delta * 2.5)
		#State.WALKING:
			#if anim["parameters/state_machine/blend_amount"] + 0.001 <= 0:
				#anim["parameters/state_machine/blend_amount"] = move_toward(anim["parameters/state_machine/blend_amount"], 0, delta * 2.5)
		#State.RUNNING:
			#if anim["parameters/state_machine/blend_amount"] + 0.001 <= 1:
				#anim["parameters/state_machine/blend_amount"] = move_toward(anim["parameters/state_machine/blend_amount"], 1, delta * 2.5)

## Start dialogue with NPC
#func interact(must_talk: bool = false):
	#if can_talk || must_talk:
		#get_tree().root.get_node("Game/PlayerUI").speak(dialogues[current_dialogue][0], dialogues[current_dialogue][1], get_path())

## Target follow target position setter.
func target_follow():
	if follow_update_timer > 0:
		follow_update_timer -= get_physics_process_delta_time()
	else:
		set_target_position(get_node(follow_target).global_position - get_node(follow_target).global_transform.basis.z * 1.5)
		follow_update_timer = 1.0

## MUST be called by moving platform when starts or ends moving.
func on_moving_platform(start: bool):
	platform_moving = start

## Wander implementation
func wander(delta: float):
	# If wander_action, the npc will walk as much as possible, also generate new rotation
	if wander_action:
		if wandering_ready:
			wandering_rotator = rng.randi_range(-15, 15)
			set_target_position(NavigationServer3D.map_get_random_point(_nav_agent.get_navigation_map(), 1, false), false)
			# set the destination with a new rotation degrees
			wandering_destination = roundi(rotation_degrees.y + wandering_rotator)
			wander_action = false
			#wandering_rotator = rng.randi_range(150, 179)
			#wandering_destination = roundi(wrapf(rotation_degrees.y + wandering_rotator, -180, 180))
	else:
		# If the destination is reached - wander
		if roundi(rotation_degrees.y) == wandering_destination:
			wander_action = true
		# If a dead end reached, rotate faster
		if wandering_rotator > 120 || wandering_rotator < -120:
			rotate_y(deg_to_rad(20 * delta))
		else:
			rotate_y(deg_to_rad(wandering_rotator * delta))

## Stop wandering for a while.
func hold_still():
	wandering = false
	await get_tree().create_timer(15.0).timeout
	wandering = true

## Make footstep sounds audible to all.
func play_footstep_sound(sprinting: bool):
	if move_sounds_enabled:
		if sprinting:
			if sprint_sounds.size() == 0:
				walk_sounds.stream = load(footstep_sounds[rng.randi_range(0, footstep_sounds.size() - 1)])
			else:
				walk_sounds.stream = load(sprint_sounds[rng.randi_range(0, sprint_sounds.size() - 1)])
			walk_sounds.play()
		else:
			walk_sounds.stream = load(footstep_sounds[rng.randi_range(0, footstep_sounds.size() - 1)])
			walk_sounds.play()

#func _on_optimizator_screen_entered() -> void:
	#visible_on_screen = true
#
#
#func _on_optimizator_screen_exited() -> void:
	#visible_on_screen = false

func on_map_updated(map: RID):
	wandering_ready = true
	NavigationServer3D.map_changed.disconnect(on_map_updated)
