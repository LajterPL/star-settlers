extends Resource
class_name Item

@export var icon : Texture2D
@export var name : StringName
@export var description : String

func _init(name : StringName, description : String = "", icon : Texture2D = null):
	self.name = name
	self.description = description
	self.icon = icon
