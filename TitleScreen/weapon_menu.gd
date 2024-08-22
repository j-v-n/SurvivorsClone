extends Control

@onready var displayWeapons: HBoxContainer = get_node("%DisplayWeapons")
@onready var labelDescription: Label = get_node("%WeaponDescription")
@onready var weaponOptions = preload("res://TitleScreen/weapon_selection.tscn")
@onready var player = get_tree().get_first_node_in_group("player")
@onready var weaponOut = get_tree().get_first_node_in_group("chosen_weapon")
# @onready var transitionGame: AnimationPlayer = get_node("%TransitionToGame")
@onready var animPlayer: AnimationPlayer = get_node("%AnimationPlayer")
@export var level1_weaponChoices: ResourceGroup
var _weapon_choices: Array[Weapon] = []

var level = preload("res://World/world.tscn")
var chosen_weapon = null

var item = null

signal starting_weapon(weapon)

func _ready():
	connect("starting_weapon", Callable(weaponOut, "get_chosen_weapon"))
	# animPlayer.play_backwards("fade")
	level1_weaponChoices.load_all_into(_weapon_choices)

	for weapon in _weapon_choices:
		var displayedWeapon = weaponOptions.instantiate()
		displayedWeapon.item = weapon
		displayWeapons.add_child(displayedWeapon)

func display_description(item: Weapon):
	if item != null:
		labelDescription.text = item.description
	else:
		labelDescription.text = "Hover over a weapon to see a description"

func start_game(weapon: Weapon):
	chosen_weapon = weapon
	emit_signal("starting_weapon", chosen_weapon)
	animPlayer.play("fade")
	

func _on_animation_player_animation_finished(anim_name: StringName):
	get_tree().change_scene_to_packed(level)
