extends Area2D

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D
@onready var sound = $sound_collected
@onready var grabTimer = get_node("%GrabTimer")
@onready var player = get_tree().get_first_node_in_group("player")

var target = null
var speed = -1

signal reduce_collision()

func _ready():
    connect("reduce_collision", Callable(player, "reduce_grabarea"))

func _physics_process(delta):
    if target != null:
        global_position = global_position.move_toward(target.global_position, speed)
        speed += 2 * delta

func collect():
    sound.play()
    collision.call_deferred("set", "disabled", true)
    sprite.visible = false
	# var xp = increase_exp()
	# return experience


func _on_grab_timer_timeout():
    emit_signal("reduce_collision")
    
func _on_sound_collected_finished():
    queue_free()
