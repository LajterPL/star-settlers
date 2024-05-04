extends Node

var player : Character = load("res://Resources/Character/test_character.tres") as Character

func set_player(character : Character):
	self.player = character
