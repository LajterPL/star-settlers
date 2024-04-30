extends Node

var player : Character = load("res://Scenes/Combat/Character/test_player.tres") as Character

func setPlayer(character : Character):
	self.player = character
