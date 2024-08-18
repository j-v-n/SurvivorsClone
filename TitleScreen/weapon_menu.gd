extends Control

@onready var displayWeapons: HBoxContainer = get_node("%DisplayWeapons")
@onready var labelDescription: Label = get_node("%Label_Description")
@onready var weaponOptions = preload("res://TitleScreen/weapon_selection.tscn")
@onready var player = get_tree().get_first_node_in_group("player")

var level = preload("res://World/world.tscn")
var chosen_weapon = null

func _ready():
    # connect("starting_weapon", Callable(player, "get_starting_weapon"))
    labelDescription.text = "Hover over a weapon to see a description"
    var weapon_choices = ["icespear1", "javelin1", "tornado1", "disc1", "fireball1"]
    for weapon_choice in weapon_choices:
        var displayedWeapon = weaponOptions.instantiate()
        displayedWeapon.item = weapon_choice
        displayWeapons.add_child(displayedWeapon)

func display_description(item):
    if item != null:
        labelDescription.text = UpgradeDb.UPGRADES[item]["details"]
    else:
        labelDescription.text = "Hover over a weapon to see a description"

func start_game(weapon):
    chosen_weapon = weapon
    get_tree().change_scene_to_packed(level)
