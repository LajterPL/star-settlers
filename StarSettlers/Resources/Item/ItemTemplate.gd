extends Resource
class_name Item

@export var icon : Texture2D = null
@export var name : StringName
@export var description : String = ""

enum ItemType {MELEE, RANGED, HEALING}
@export var type: ItemType = ItemType.MELEE
@export var values : Dictionary = {}
