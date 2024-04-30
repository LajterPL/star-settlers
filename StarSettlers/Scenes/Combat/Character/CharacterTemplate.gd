extends Resource
class_name Character

@export var icon : Texture2D
@export var name : StringName
@export var description : String

@export var equipment : Equipment

@export var strenght : int
@export var agility : int

@export var max_hp : int
@export var current_hp : int

func _init(	name : StringName = &"", description : String = "", 
			icon : Texture2D = null, equipment : Equipment = null,
			strenght : int = 0, agility : int = 0, 
			max_hp : int = 0, current_hp : int = 0):
	self.name = name
	self.description = description
	self.icon = icon
	self.equipment = equipment
	self.strenght = strenght
	self.agility = agility
	self.max_hp = max_hp
	self.current_hp = current_hp
