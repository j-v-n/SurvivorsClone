extends Area2D

@export var damage = 1

@onready var collision = get_node("%CollisionShape2D")
@onready var disableTimer = get_node("%disableHitBoxTimer")

func tempdisable():
	collision.call_deferred("set","disabled",true)
	disableTimer.start()


func _on_disable_hit_box_timer_timeout():
	collision.call_deferred("set","disabled",false)
