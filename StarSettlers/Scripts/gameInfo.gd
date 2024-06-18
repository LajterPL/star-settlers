extends Node

var player : Character = load("res://Resources/Character/test_character.tres") as Character
var map : TileMap
var base_eq : Equipment

func _ready():
	player = load("res://Resources/Character/StartingCharacters/player_dingo.tres") as Character
	map = null
	
	base_eq = Equipment.new()
	base_eq.max_size = 25

func set_player(character : Character):
	self.player = character
