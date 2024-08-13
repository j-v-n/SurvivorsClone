extends Area2D

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D
@onready var player = get_tree().get_first_node_in_group("player")
@onready var attackTimer = get_node("%AttackTimer")
@onready var removeTimer = get_node("%RemoveFromArrayTimer")
@onready var coolDownTimer = get_node("%CoolDownTimer")
@onready var animPlayer = get_node("%AnimationPlayer")


# starting stats
var level = 1
var hp = 1
var speed = 100
var damage = 5
var knockback_amount = 100
var attack_size = 1.0
var attack_speed = 5.0

func _ready():
	var atk = true
	animPlayer.play("spin")
	update_disc()
	spawn_disc(atk)

func update_disc():
	level = player.disc_level
	print("level: ", level)
	#coolDownTimer.stop()
	match level:
		1:
			hp = 999
			damage = 20
			knockback_amount = 100
			attack_size = 2.0 * (1 + player.spell_size)
			attack_speed = 5.0 * (1 + player.spell_cooldown)
		
		2:
			hp = 999
			damage = 25
			knockback_amount = 100
			attack_size = 2.0 * (1 + player.spell_size)
			attack_speed = 5.0 * (1 + player.spell_cooldown)
		
		3:
			hp = 999
			damage = 30
			knockback_amount = 120
			attack_size = 2.0 * (1 + player.spell_size)
			attack_speed = 5.0 * (1 + player.spell_cooldown)
		
		4:
			hp = 999
			damage = 30
			knockback_amount = 126
			attack_size = 2.0 * (1 + player.spell_size)
			attack_speed = 5.0 * (1 + player.spell_cooldown)
	
	attackTimer.wait_time = attack_speed
	coolDownTimer.wait_time = 5.0 * (1 - player.spell_cooldown)
	#attackTimer.start()

func spawn_disc(atk):
	var available_attack_time = attackTimer.wait_time
	var available_cooldown_time = coolDownTimer.wait_time
	var tween = create_tween()
	print(attack_size, " ", available_attack_time)
	if atk:
		tween.tween_property(self, "scale", Vector2(attack_size, attack_size), available_attack_time / 10).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		tween.play()
	else:
		tween.tween_property(self, "scale", Vector2(0.1, 0.1), available_cooldown_time / 10).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		tween.play()

func _on_attack_timer_timeout():
	var atk = false
	spawn_disc(atk)
	coolDownTimer.start()
	collision.call_deferred("set", "disabled", true)


func _on_cool_down_timer_timeout():
	var atk = true
	attackTimer.start()
	spawn_disc(atk)
	collision.call_deferred("set", "disabled", false)
	
func _physics_process(delta):
	global_position = player.global_position
	#update_disc()

func persist():
	pass
