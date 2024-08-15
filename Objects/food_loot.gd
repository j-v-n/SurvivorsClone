extends Area2D

@export var health_points = 20

var target = null
var speed = -1

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D
@onready var sound = $sound_collected


func _physics_process(delta):
    if target != null:
        global_position = global_position.move_toward(target.global_position, speed)
        speed += 2 * delta

func collect():
    sound.play()
    collision.call_deferred("set", "disabled", true)
    sprite.visible = false
    return health_points

func increase_hp():
    pass

func _on_sound_collected_finished():
    queue_free()
