extends Node

var player : Resource = load("res://Scenes/Combat/Character/test_player.tres")

func setPlayer(character : Character):
	self.player = character
