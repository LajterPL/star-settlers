extends Resource
class_name Character

@export var icon : Texture2D = null
@export var name : StringName
@export var description : String = ""

@export var equipment : Equipment = Equipment.new()

@export var strenght : int = 0
@export var agility : int = 0

@export var max_hp : int = 0
@export var current_hp : int = 0
