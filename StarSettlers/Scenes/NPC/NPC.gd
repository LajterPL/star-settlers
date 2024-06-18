extends Node2D

@onready var tile_map: TileMap = $"../TileMap"
@onready var player = $"../Player"
@onready var ui = $"../PlayerCamera/UI"

var chat_instance = null
var fight_instance = null
var player_in_chat_zone = false
var basic_stats: Character
var npc_speed = 1.75

var is_roaming = true
var is_chatting = false
var chatting_range = 4
var view_range = 8
var faceing_right = true
var start_pos

var roaming_radius
var roaming_area
var direction: Vector2i
var current_path: Array[Vector2i]

enum state{
	IDLE,
	NEW_DIR,
	MOVE
}
var current_state:state = state.NEW_DIR

enum relation{
	LOYAL,
	FRIENDLY,
	NEUTRAL,
	UNFRIENDLY,
	AGRESIVE
}
var current_relation:relation = relation.NEUTRAL

func _ready():
	basic_stats = load("res://Scenes/NPC/npc.tres") as Character
	randomize()
	start_pos = position
	roaming_radius = 15 
	roaming_area = set_roaming_area(start_pos,roaming_radius)
	current_state = state.IDLE
	current_relation = relation.NEUTRAL
	
	
func set_roaming_area(pos, rad):
	var start_tile = tile_map.local_to_map(pos)
	var area = []
	for row in  range(start_tile.y-roaming_radius, start_tile.y+roaming_radius):
		for col in  range(start_tile.x-roaming_radius, start_tile.x+roaming_radius):
			var tile_data = tile_map.get_cell_tile_data(0,Vector2i(row,col),false)
			if distance(start_tile,Vector2i(col,row))<rad-1:
				if tile_data != null and tile_data.get_custom_data("walkable"):
					#tile_map.set_cell(0,Vector2i(row,col),3,Vector2i(1,1))
					area.append(Vector2i(row,col))

	return area
#tile_map.set_cell(0,Vector2i(row,col),3,Vector2i(1,1))

func _process(delta):
	if current_state == 0 or current_state == 1:
		#AnimationPlayer.play(IDLE)
		pass
	elif current_state == 2 and !is_chatting:
		#AnimationPlayer.play(walking)
		pass
	
	if is_roaming:
		match current_state:
			state.IDLE:
				pass
			state.NEW_DIR:
				set_direction()
				current_state = state.MOVE
			state.MOVE:
				move()
		
	if can_chat() and (current_relation == relation.AGRESIVE or current_relation  == relation.UNFRIENDLY):
		#if fight_instance == null:
		#	var fight_scene = preload("res://Scenes/Combat/ComabatScreen.tscn")
		#	fight_instance = fight_scene.instantiate()
		#	add_child(fight_instance)
			#print("fight")
		pass
	elif can_chat() and Input.is_action_just_pressed("chat") and chat_instance == null:
		chat()
	
	if chat_instance != null and !can_chat():
		end_chat()

		
		#play IDLE animation
func can_stand(x: Vector2i):
	return tile_map.get_cell_tile_data(0,x,false).get_custom_data("walkable")

func set_direction():
	if current_relation == relation.AGRESIVE:
		direction = tile_map.local_to_map(player.position)
		current_path = tile_map.a_star_path(tile_map.local_to_map(position), direction)
		current_path.pop_back()	
	else:
		direction = choose(roaming_area)
		current_path = tile_map.a_star_path(tile_map.local_to_map(position), direction)
				
func can_see_player():
	return distance(tile_map.local_to_map(player.position),
				tile_map.local_to_map(position)) <= view_range
	
func can_chat():
	return distance(tile_map.local_to_map(player.position),
				tile_map.local_to_map(position)) <= chatting_range

func move():
	if is_chatting or current_path.is_empty():
		return
	var target_position = tile_map.map_to_local(current_path.front())
	if current_relation == relation.AGRESIVE:
		npc_speed = 3
	else:
		npc_speed = 1.75
	global_position = global_position.move_toward(target_position, npc_speed)
	if global_position == target_position:
		current_path.pop_front()
	if current_path.is_empty():
		current_state = state.IDLE
		
	
func chat():
	var chat_scene = preload("res://Scenes/Dialog/DialogScreen.tscn")
	chat_instance = chat_scene.instantiate()
	ui.add_child(chat_instance)
	
	chat_instance.move_to_front()
	chat_instance.connect("dialog_ended", end_chat)
	
	is_roaming = false
	is_chatting = true
	#chat_instance.position = position + Vector2(100, -250)
	
func end_chat():
	chat_instance.queue_free()
	
	chat_instance = null
	is_chatting = false
	is_roaming = true
	
func choose(array: Array):
	return array[randi() % array.size()]


func distance(start: Vector2i, target: Vector2i):
	var distance = sqrt((start.x-target.x)**2+(start.y-target.y)**2)
	return distance


func change_in_relation(better: bool):
	if better:
		match current_relation:
			relation.LOYAL:
				pass
			relation.FRIENDLY:
				current_relation = relation.LOYAL
			relation.NEUTRAL:
				current_relation = relation.FRIENDLY
			relation.UNFRIENDLY:
				current_relation = relation.NEUTRAL
			relation.AGRESIVE:
				current_relation = relation.UNFRIENDLY
	else:
		match current_relation:
			relation.LOYAL:
				current_relation = relation.FRIENDLY
			relation.FRIENDLY:
				current_relation = relation.NEUTRAL
			relation.NEUTRAL:
				current_relation = relation.UNFRIENDLY
			relation.UNFRIENDLY:
				current_relation = relation.AGRESIVE
			relation.AGRESIVE:
				pass


func _on_timer_timeout():
	if current_path.is_empty():
		$Timer.wait_time = choose([0.5,1,1.5])
		current_state = choose([state.IDLE,state.IDLE,state.NEW_DIR])
	

