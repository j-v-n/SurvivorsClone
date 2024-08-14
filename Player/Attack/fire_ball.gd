extends Area2D

var level = 1
var hp = 1
var speed = -10
var damage = 5
var knockback_amount = 100
var attack_size = 1.0
var attack_speed = 4.0
var target = Vector2.ZERO
var angle = Vector2.ZERO

var time = 0.0
var rot_speed = 5
var radius = 30
var theta = 0
@onready var player = get_tree().get_first_node_in_group("player")
@onready var attackTimer = get_node("%AttackTimer")
signal remove_from_array(object)


func _ready():
	angle = global_position.direction_to(target)
	
	match level:
		1:
			hp = 5
			speed = -50
			damage = 15
			knockback_amount = -100
			attack_size = 1.0 * (1 + player.spell_size)
			attack_speed = 5.0 * (1 - player.spell_cooldown)
		2:
			hp = 5
			speed = -50
			damage = 20
			knockback_amount = -100
			attack_size = 1.0 * (1 + player.spell_size)
			attack_speed = 5.0 * (1 - player.spell_cooldown)
		3:
			hp = 5
			speed = -75
			damage = 20
			knockback_amount = -100
			attack_size = 1.0 * (1 + player.spell_size)
			attack_speed = 5.0 * (1 - player.spell_cooldown)
		4:
			hp = 5
			speed = -100
			damage = 25
			knockback_amount = -125
			attack_size = 1.0 * (1 + player.spell_size)
			attack_speed = 5.0 * (1 - player.spell_cooldown)

	attackTimer.wait_time = attack_speed
	attackTimer.start()
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(0.25, 0.25) * attack_size, 2).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.play()

func _physics_process(delta):
	time += delta
	position = Vector2(
		sin((time * rot_speed) + deg_to_rad(theta)) * radius,
		cos((time * rot_speed) + deg_to_rad(theta)) * radius) + player.global_position

func enemy_hit(charge = 1):
	hp -= charge
	if hp <= 0:
		emit_signal("remove_from_array", self)
		queue_free()


func _on_attack_timer_timeout():
	emit_signal("remove_from_array", self)
	queue_free()
