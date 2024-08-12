extends Area2D

@onready var sprite = $Sprite2D
@onready var player = get_tree().get_first_node_in_group("player")
@onready var attackTimer = get_node("%AttackTimer")
@onready var coolDownTimer = get_node("%CoolDownTimer")
@onready var animPlayer = get_node("%AnimationPlayer")
signal remove_from_array(object)

# starting stats
var level = 1
var hp = 1
var speed = 100
var damage = 5
var knockback_amount = 100
var attack_size = 1.0


func _ready():
	var atk = true
	attackTimer.start()
	animPlayer.play("spin")
	spawn_disc(atk)
	

func spawn_disc(atk):
	var available_attack_time = attackTimer.wait_time
	var available_cooldown_time = coolDownTimer.wait_time
	var tween = create_tween()
	if atk:
		tween.tween_property(self,"scale",Vector2(1,1),available_attack_time/10).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		tween.play()
	else:
		tween.tween_property(self,"scale",Vector2(0.1,0.1),available_cooldown_time/10).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		#tween.tween_property(self,"visible",false,available_cooldown_time/10).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		tween.play()

func _on_attack_timer_timeout():
	var atk = false
	spawn_disc(atk)
	coolDownTimer.start()

func _on_cool_down_timer_timeout():
	var atk = true
	attackTimer.start()
	spawn_disc(atk)
	
