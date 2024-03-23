extends VBoxContainer

@onready var dialogContainer = $DialogScrollContainer/DialogContainer
@onready var dialogOptions = $DialogOptions

var dialogQueue : Array[Variant] = []
var dialogDecision : Array[Variant] = []

func _ready():
	load_dialog("res://Scenes/Dialog/test_dialog.json")
	progress_dialog()

func load_dialog(path : String):
	var json_string = FileAccess.get_file_as_string(path)
	var data = JSON.parse_string(json_string)
	
	if data == null:
		push_error("Nie udało się odczytać pliku z dialogiem")
		return
	
	dialogQueue = data

func _input(event):
	if event is InputEventScreenTouch:
		if not event.is_pressed():
			if self.get_rect().has_point(event.position):
				progress_dialog()

func progress_dialog():
	if dialogQueue.size() > 0:
		dialogOptions.hide()
		
		var nextDialog = dialogQueue.pop_front()
		
		var newLabel : RichTextLabel = RichTextLabel.new()
		newLabel.text = nextDialog.content
		newLabel.fit_content = true
		newLabel.scroll_active = false
		newLabel.focus_mode = Control.FOCUS_CLICK
		dialogContainer.add_child(newLabel)
		
		if nextDialog.type == "decision":
			dialogOptions.show()
			
			for i in range(dialogOptions.get_child_count()):
				dialogOptions.get_child(i).hide()
			
			for i in range(nextDialog.options.size()):
				var button = dialogOptions.get_child(i)
				button.text = nextDialog.options[i].title
				button.show()
			
			dialogDecision = nextDialog.options
	

func choose_option(idx : int):
	dialogQueue = dialogDecision[idx].queue
	progress_dialog()


func _button_1_pressed():
	choose_option(0)

func _button_2_pressed():
	choose_option(1)


func _button_3_pressed():
	choose_option(2)

func _button_4_pressed():
	choose_option(3)