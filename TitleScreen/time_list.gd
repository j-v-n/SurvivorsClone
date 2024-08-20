extends Control

@onready var timeContainer: VBoxContainer = get_node("%TimeContainer")
# @onready var player = get_tree().get_first_node_in_group("player")
var mainMenu = "res://TitleScreen/menu.tscn"

var loader: SaverLoader = SaverLoader.new()
var tenderness_font = load("res://Font/tenderness.otf")
const filepath: String = "user://savedtime.json"

func _ready():
	var saved_times = times_to_display()
	
	if saved_times.size() > 0:
		var formatted_times = format_times(saved_times)
		for formatted_time in formatted_times:
			var newLabel = Label.new()
			newLabel.text = formatted_time
			newLabel.horizontal_alignment = 1
			newLabel.vertical_alignment = 1
			newLabel.set("theme_override_fonts/font", tenderness_font)
			timeContainer.add_child(newLabel)


func times_to_display():
	if FileAccess.file_exists(filepath):
		var saved_data = loader.read_file(filepath)
		var run_times = saved_data["run_times"]
		# sort in ascending order
		run_times.sort()
		# reverse 
		run_times.reverse()
		if run_times.size() >= 5:
			# get first 5
			return run_times.slice(0, 4)
		else:
			# get all since length will be less than 5
			return run_times
	else:
		return []

func format_times(array: Array):
	if array.size() > 0:
		var formatted_times: Array[String] = []
		for time in array:
			var get_m = int(time / 60)
			var get_s = int(time) % 60
			if get_m < 10:
				get_m = str(0, get_m)
			if get_s < 10:
				get_s = str(0, get_s)
			formatted_times.append(str(get_m, ":", get_s))
		return formatted_times

		
func _on_back_button_click_end():
	get_tree().change_scene_to_file(mainMenu)
