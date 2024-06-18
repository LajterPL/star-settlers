extends Node

var player : Character = load("res://Resources/Character/test_character.tres") as Character
var map : TileMap

func _ready():
	player = load("res://Resources/Character/StartingCharacters/player_dingo.tres") as Character
	map = null

func set_player(character : Character):
	self.player = character
