@tool
extends EditorPlugin

var attempt: int = 0

func _enter_tree() -> void:
	add_autoload_singleton("ResourceDB", "res://addons/godot-visual-novel/Autoloads/ResourceDB.gd")
	add_autoload_singleton("Variables", "res://addons/godot-visual-novel/Autoloads/Variables.gd")


func _exit_tree() -> void:
	remove_autoload_singleton("ResourceDB")
	remove_autoload_singleton("Variables")
