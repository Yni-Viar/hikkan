extends Resource
## House map generator
## Made by Yni, licensed under MIT License
class_name HouseGenZone


## Rooms
@export var rooms: Array[PackedScene] = []
## Single rooms
@export var rooms_single: Array[PackedScene] = []
@export_group("Door frames")
## Doors
@export var door_frames: Array[PackedScene] = []
## End door material to generate
@export var end_door_material: Material
