extends ColorRect

@onready var weaponIcon: TextureRect = get_node("%WeaponIcon")
@onready var weapon_menu = get_tree().get_first_node_in_group("menu_weapon_selection")

var mouse_over = false
var item = null

signal hovered_weapon(weapon)
signal selected_weapon(weapon)

func _ready():
    connect("hovered_weapon", Callable(weapon_menu, "display_description"))
    connect("selected_weapon", Callable(weapon_menu, "start_game"))
    weaponIcon.texture = load(UpgradeDb.UPGRADES[item]["icon"])

func _input(event):
    if event.is_action("click"):
        if mouse_over:
            emit_signal("selected_weapon", item)


func _on_weapon_icon_mouse_exited():
    mouse_over = false
    # emit_signal("hovered_weapon", null)


func _on_weapon_icon_mouse_entered():
    mouse_over = true
    emit_signal("hovered_weapon", item)
