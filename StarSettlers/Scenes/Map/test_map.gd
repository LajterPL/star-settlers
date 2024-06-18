extends Node2D

@onready var npc = preload("res://Scenes/NPC/NPC.tscn")
@onready var player = $Player 
@onready var bg_music = $bg_music

# Called when the node enters the scene tree for the first time.
func _ready():
	bg_music.play()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_bg_music_finished():
	bg_music.play()
