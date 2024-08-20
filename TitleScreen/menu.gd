extends Control

@onready var transition: AnimationPlayer = get_node("%Transition")
var level = preload("res://TitleScreen/weapon_menu.tscn")
var timesList = preload("res://TitleScreen/time_list.tscn")
# var times = null

func _on_button_play_click_end():
	transition.play("fade_out")
	# var _level = get_tree().change_scene_to_file(level)
	

func _on_button_quit_click_end():
	get_tree().quit()

func _on_button_times_click_end():
	get_tree().change_scene_to_packed(timesList)


func _on_transition_animation_finished(anim_name: StringName):
	get_tree().change_scene_to_packed(level)
