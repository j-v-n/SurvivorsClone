extends CharacterBody2D

@export var movement_speed = 20.0
@export var hp = 10
@export var knockback_recovery = 3.5
@export var experience = 1
@export var enemy_damage = 1
@export var gem_weight = 1.0
@export var orb_weight = 0.1
@export var food_weight = 0.1

var object_types = {
	"gem":
		{"roll_weight": gem_weight, "acc_weight": null},
	"orb":
		{"roll_weight": orb_weight, "acc_weight": null},
	"food":
		{"roll_weight": food_weight, "acc_weight": null}}

var total_weight = 0.0
var knockback = Vector2.ZERO

@onready var player = get_tree().get_first_node_in_group("player")
@onready var sprite = get_node("%Sprite2D")
@onready var animPlayer = get_node("%AnimationPlayer")
@onready var sound_hit = get_node("%sound_hit")
@onready var hitBox = $HitBox

@onready var loot_base = get_tree().get_first_node_in_group("loot")

var death_anim = preload("res://Enemy/explosion.tscn")
var exp_gem = preload("res://Objects/experience_gem.tscn")
var food_loot = preload("res://Objects/food_loot.tscn")
var orb = preload("res://Objects/orb.tscn")

signal remove_from_array(object)


func _ready():
	# because we want the enemies to constantly be walking 
	# unlike the player who you only want to walk when you're moving
	# it is easier to just use an animation player
	
	# alternatively you can just use a walkTimer without checking for
	# whether direction is a non-zero vector
	animPlayer.play("walk")
	hitBox.damage = enemy_damage
	init_probabilities()

func _physics_process(_delta):
	knockback = knockback.move_toward(Vector2.ZERO, knockback_recovery)
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * movement_speed
	velocity += knockback
	move_and_slide()
	
	if direction.x > 0.2:
		sprite.flip_h = true
	elif direction.x < -0.2:
		sprite.flip_h = false

func death():
	emit_signal("removed_from_array", self)
	var enemy_death = death_anim.instantiate()
	enemy_death.scale = sprite.scale
	enemy_death.global_position = global_position
	get_parent().call_deferred("add_child", enemy_death)
	var loot = pick_loot()
	if loot == "gem":
		var new_gem = exp_gem.instantiate()
		new_gem.global_position = global_position
		new_gem.experience = experience
		loot_base.call_deferred("add_child", new_gem)
	elif loot == "orb":
		var new_orb = orb.instantiate()
		new_orb.global_position = global_position
		loot_base.call_deferred("add_child", new_orb)
	else:
		var new_food = food_loot.instantiate()
		new_food.global_position = global_position
		# new_food.hp = hp
		loot_base.call_deferred("add_child", new_food)
	queue_free()
	

func _on_hurt_box_hurt(damage, angle, knockback_amount):
	hp -= damage
	knockback = angle * knockback_amount
	if hp <= 0:
		death()
	else:
		sound_hit.play()

func init_probabilities() -> void:
	total_weight = 0.0
	for obj in object_types:
		total_weight += object_types[obj]["roll_weight"]
		object_types[obj]["acc_weight"] = total_weight

func pick_loot():
	var roll: float = randf_range(0.0, total_weight)
	for obj in object_types:
		if (object_types[obj]["acc_weight"] > roll):
			return obj
	return {}
