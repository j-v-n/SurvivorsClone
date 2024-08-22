extends CharacterBody2D

@export var movement_speed = 40.0


@onready var sprite = get_node("%Sprite2D")
@onready var walkTimer = get_node("%walkTimer")

# gui
@onready var expBar = get_node("%ExperienceBar")
@onready var label_level = get_node("%label_level")
@onready var levelPanel = get_node("%LevelUp")
@onready var upgradeOptions = get_node("%UpgradeOptions")
@onready var sound_levelup = get_node("%sound_levelup")
@onready var itemOptions = preload("res://Utility/item_option.tscn")
@onready var healthBar = get_node("%HealthBar")
@onready var labelTimer = get_node("%LabelTimer")
@onready var collectedWeapons = get_node("%CollectedWeapons")
@onready var collectedUpgrades = get_node("%CollectedUpgrades")
@onready var itemContainer = preload("res://Player/GUI/item_container.tscn")
@onready var invincibilityTimer = get_node("%InvincibilityTimer")
@onready var invincibilityCooldown = get_node("%InvincibilityCooldown")
@onready var deathPanel = get_node("%DeathPanel")
@onready var labelResult = get_node("%label_Result")
@onready var soundVictory = get_node("%sound_victory")
@onready var soundLose = get_node("%sound_lose")
@onready var playerCollision = get_node("%PlayerCollision")
@onready var grabAreaCollision = get_node("%GrabAreaCollision")
@onready var dustParticles: CPUParticles2D = get_node("%Dust")
@onready var transition: AnimationPlayer = get_node("%TransitionToMain")
@onready var _saver_loader: SaverLoader = get_node("%SaverLoader")

signal playerDeath

#Attacks
var iceSpear = preload("res://Player/Attack/ice_spear.tscn")
var tornado = preload("res://Player/Attack/tornado.tscn")
var javelin = preload("res://Player/Attack/javelin.tscn")
var spinningDisc = preload("res://Player/Attack/spinning_disc.tscn")
var fireBall = preload("res://Player/Attack/fire_ball.tscn")
#AttackNodes
@onready var iceSpearTimer = get_node("%IceSpearTimer")
@onready var iceSpearAttackTimer = get_node("%IceSpearAttackTimer")
@onready var tornadoTimer = get_node("%TornadoTimer")
@onready var tornadoAttackTimer = get_node("%TornadoAttackTimer")
@onready var fireBallTimer = get_node("%FireBallTimer")
@onready var fireBallWaitTimer = get_node("%FireBallWaitTimer")
@onready var javelinBase = get_node("%JavelinBase")
@onready var discBase = get_node("%DiscBase")
@onready var fireBase = get_node("%FireBallBase")
# Upgrades
var collected_upgrades = []
var upgrade_options = []
var armor = 0
var speed = 0
var spell_cooldown = 0
var spell_size = 0
var additional_attacks = 0
var invincibility_time = 0
var invincibility_cooldown = 0
# IceSpear
var icespear_ammo = 0
var icespear_baseammo = 0
var icespear_attackspeed = 1.5
var icespear_level = 0

# Tornado
var tornado_ammo = 0
var tornado_baseammo = 0
var tornado_attackspeed = 3
var tornado_level = 0

# Javelin
var javelin_ammo = 0
var javelin_level = 0

# Disc
var disc_level = 0

# Fireball
var fireball_level = 0
var fireball_ammo = 0
var fireball_baseammo = 0
var fireball_attackspeed = 1.5

#Enemy related
var enemy_close = []

var hp = 80
var last_movement = Vector2.UP
var experience = 0
var experience_level = 1
var collected_experience = 0
var maxhp = 80
var time = 0
var weapon: Object

#func get_starting_weapon(weapon):
	#print("entered signal")
	#if weapon != null:
		#return weapon

func _ready():
	dustParticles.emitting = false
	dustParticles.global_position = global_position + Vector2(0, 10)
	#upgrade_character(ChosenWeapon.weapon_choice)
	upgrade_character("icespear1")
	#var chosen_weapon = WeaponMenu.chosen_weapon
	#upgrade_character(chosen_weapon)
	attack()
	set_expbar(experience, calculate_experience_cap())
	_on_hurt_box_hurt(0, 0, 0)
	
func attack():
	if icespear_level > 0:
		iceSpearTimer.wait_time = icespear_attackspeed * (1 - spell_cooldown)
		if iceSpearTimer.is_stopped():
			iceSpearTimer.start()
	
	if tornado_level > 0:
		tornadoTimer.wait_time = tornado_attackspeed * (1 - spell_cooldown)
		if tornadoTimer.is_stopped():
			tornadoTimer.start()
	
	if javelin_level > 0:
		spawn_javelin()
		
	if disc_level > 0:
		spawn_disk()
	
	if fireball_level > 0:
		# # add way to not immediately spawn next fireball when upgrade is collected
		# if additional_attacks > 1:
		# 	fireBallTimer.stop()
		# else:
		spawn_fireballs()


func _physics_process(delta):
	# every single frame
	movement()
	dustParticles.global_position = global_position + Vector2(0, 15)
	

func movement():
	var x_mov = Input.get_action_strength("right") - Input.get_action_strength("left")
	var y_mov = Input.get_action_strength("down") - Input.get_action_strength("up")
	var mov = Vector2(x_mov, y_mov)
	
	#flip sprite based on direction of movement
	if mov.x > 0:
		# dustParticles.emitting = false
		sprite.flip_h = true
		dustParticles.gravity = Vector2(-200, 10)
	elif mov.x < 0:
		sprite.flip_h = false
		dustParticles.gravity = Vector2(200, 10)
	elif mov.x == 0:
		if mov.y > 0:
			dustParticles.gravity = Vector2(0, -10)
		if mov.y < 0:
			dustParticles.gravity = Vector2(0, 10)

	if mov != Vector2.ZERO:
		dustParticles.emitting = true
		last_movement = mov
		if walkTimer.is_stopped():
			if sprite.frame >= sprite.hframes - 1:
				sprite.frame = 0
			else:
				sprite.frame = 1
			walkTimer.start()
	else:
		dustParticles.emitting = false
		
	velocity = mov.normalized() * movement_speed
	# now do move and slide
	move_and_slide()

func _on_hurt_box_hurt(damage, _angle, _knockback):
	hp -= clamp(damage - armor, 1.0, 999.0)
	healthBar.max_value = maxhp
	healthBar.value = hp
	if hp <= 0:
		death()


func _on_ice_spear_timer_timeout():
	icespear_ammo += icespear_baseammo + additional_attacks
	iceSpearAttackTimer.start()


func _on_ice_spear_attack_timer_timeout():
	if icespear_ammo > 0:
		var icespear_attack = iceSpear.instantiate()
		icespear_attack.position = position
		icespear_attack.target = get_random_target()
		icespear_attack.level = icespear_level
		add_child(icespear_attack)
		icespear_ammo -= 1
		if icespear_ammo > 0:
			iceSpearAttackTimer.start()
		else:
			iceSpearAttackTimer.stop()

func _on_tornado_timer_timeout():
	tornado_ammo += tornado_baseammo + additional_attacks
	tornadoAttackTimer.start()


func _on_tornado_attack_timer_timeout():
	if tornado_ammo > 0:
		var tornado_attack = tornado.instantiate()
		tornado_attack.position = position
		tornado_attack.last_movement = last_movement
		tornado_attack.level = tornado_level
		add_child(tornado_attack)
		tornado_ammo -= 1
		if tornado_ammo > 0:
			tornadoAttackTimer.start()
		else:
			tornadoAttackTimer.stop()

func spawn_javelin():
	var get_javelin_total = javelinBase.get_child_count()
	var calc_spawns = javelin_ammo + additional_attacks - get_javelin_total
	
	while calc_spawns > 0:
		var javelin_spawn = javelin.instantiate()
		javelin_spawn.global_position = global_position
		javelinBase.add_child(javelin_spawn)
		calc_spawns -= 1
	# update javelin
	var get_javelins = javelinBase.get_children()
	for i in get_javelins:
		if i.has_method("update_javelin"):
			i.update_javelin()

# func _on_fire_ball_wait_timer_timeout():
# 	pass # Replace with function body.


func _on_fire_ball_timer_timeout():
	spawn_fireballs()
	fireBallTimer.start()

func spawn_fireballs():
	var get_fireballs_total = fireBase.get_child_count()
	# fireball_ammo += fireball_baseammo + additional_attacks
	var calc_spawns = fireball_baseammo + additional_attacks - get_fireballs_total
	var spawn_thetas = [0, 180, 90, 270]
	while calc_spawns > 0:
		var fireball_spawn = fireBall.instantiate()
		var spawn_theta = spawn_thetas[calc_spawns - 1]
		spawn_thetas.erase(spawn_theta)
		fireball_spawn.theta = spawn_theta
		fireball_spawn.position = global_position + Vector2(sin(deg_to_rad(fireball_spawn.theta) * fireball_spawn.radius), cos(deg_to_rad(fireball_spawn.theta) * fireball_spawn.radius))
		# fireball_spawn.target = global_position
		fireball_spawn.level = fireball_level
		fireBase.add_child(fireball_spawn)
		calc_spawns -= 1
	if fireBallTimer.is_stopped():
			fireBallTimer.start()

func spawn_disk():
	var get_discs = discBase.get_children()
	if get_discs.size() == 0:
		var disc_spawn = spinningDisc.instantiate()
		disc_spawn.global_position = global_position
		discBase.add_child(disc_spawn)
		disc_spawn.update_disc()
	else:
		for disc in get_discs:
			disc.update_disc()


func get_random_target():
	if enemy_close.size() > 0:
		return enemy_close.pick_random().global_position
	else:
		return Vector2.UP


func _on_enemy_detection_area_body_entered(body):
	if not enemy_close.has(body):
		enemy_close.append(body)


func _on_enemy_detection_area_body_exited(body):
	if enemy_close.has(body):
		enemy_close.erase(body)


func _on_grab_area_area_entered(area):
	if area.is_in_group("loot"):
		area.target = self


func _on_collect_area_area_entered(area):
	if area.is_in_group("loot"):
		if area.has_method("increase_exp"):
			var gem_experience = area.collect()
			calculate_experience(gem_experience)
		elif area.has_method("increase_hp"):
			var food_hp = area.collect()
			calculate_hp(food_hp)
		else:
			area.collect()
			expand_grabarea()
			area.grabTimer.start()

func expand_grabarea():
	grabAreaCollision.shape.radius = 500
	
func reduce_grabarea():
	grabAreaCollision.shape.radius = 50


func calculate_experience(gem_exp):
	var exp_required = calculate_experience_cap()
	collected_experience += gem_exp
	# level up
	if experience + collected_experience >= exp_required:
		collected_experience -= exp_required - experience
		experience_level += 1
		experience = 0
		exp_required = calculate_experience_cap()
		levelup()
		
	else:
		experience += collected_experience
		collected_experience = 0
	
	set_expbar(experience, exp_required)

func calculate_hp(food_hp):
	hp += food_hp
	hp = clamp(hp, 0, maxhp)
	# hp += clamp(food_hp, 1.0, 999.0)
	# healthBar.max_value = maxhp
	healthBar.value = hp


func calculate_experience_cap():
	var exp_cap = experience_level
	
	if experience_level < 20:
		exp_cap = experience_level * 5
	elif experience_level < 40:
		exp_cap = 95 + (experience_level - 19) * 8
	else:
		exp_cap = 255 + (experience_level - 39) * 12
	return exp_cap

func set_expbar(set_value = 1, set_max_value = 100):
	expBar.value = set_value
	expBar.max_value = set_max_value

func levelup():
	sound_levelup.play()
	label_level.text = str("Level: ", experience_level)
	var tween = levelPanel.create_tween()
	tween.tween_property(levelPanel, "position", Vector2(220, 50), 0.2).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	tween.play()
	levelPanel.visible = true
	var options = 0
	var optionsmax = 3
	while options < optionsmax:
		var option_choice = itemOptions.instantiate()
		option_choice.item = get_random_item()
		upgradeOptions.add_child(option_choice)
		options += 1
	get_tree().paused = true

func upgrade_character(upgrade):
	match upgrade:
		"icespear1":
			icespear_level = 1
			icespear_baseammo += 1
		"icespear2":
			icespear_level = 2
			icespear_baseammo += 1
		"icespear3":
			icespear_level = 3
		"icespear4":
			icespear_level = 4
			icespear_baseammo += 2
		"tornado1":
			tornado_level = 1
			tornado_baseammo += 1
		"tornado2":
			tornado_level = 2
			tornado_baseammo += 1
		"tornado3":
			tornado_level = 3
			tornado_attackspeed -= 0.5
		"tornado4":
			tornado_level = 4
			tornado_baseammo += 1
		"javelin1":
			javelin_level = 1
			javelin_ammo = 1
		"javelin2":
			javelin_level = 2
		"javelin3":
			javelin_level = 3
		"javelin4":
			javelin_level = 4
		"disc1":
			disc_level = 1
		"disc2":
			disc_level = 2
		"disc3":
			disc_level = 3
		"disc4":
			disc_level = 4
		"fireball1":
			fireball_level = 1
			fireball_baseammo += 2
		"fireball2":
			fireball_level = 2
		"fireball3":
			fireball_level = 3
		"fireball4":
			fireball_level = 4
		"armor1", "armor2", "armor3", "armor4":
			armor += 1
		"speed1", "speed2", "speed3", "speed4":
			movement_speed += 20.0
		"tome1", "tome2", "tome3", "tome4":
			spell_size += 0.10
		"scroll1", "scroll2", "scroll3", "scroll4":
			spell_cooldown += 0.05
		"ring1", "ring2":
			additional_attacks += 1
		"cloak1":
			invincibility_time = 3
			invincibility_cooldown = 15
		"food":
			hp += 20
			hp = clamp(hp, 0, maxhp)
	
	if upgrade == "cloak1":
		invincible()

	adjust_gui_collection(upgrade)
	attack()
	var option_children = upgradeOptions.get_children()
	for i in option_children:
		i.queue_free()
	upgrade_options.clear()
	collected_upgrades.append(upgrade)
	levelPanel.visible = false
	levelPanel.position = Vector2(800, 50)
	get_tree().paused = false
	calculate_experience(0)

func invincible():
	invincibilityTimer.wait_time = invincibility_time
	invincibilityCooldown.wait_time = invincibility_cooldown
	playerCollision.call_deferred("set", "disabled", true)
	sprite.self_modulate.a = 0.5
	invincibilityTimer.start()

func _on_invincibility_timer_timeout():
	playerCollision.call_deferred("set", "disabled", false)
	sprite.self_modulate.a = 1
	invincibilityCooldown.start()

func _on_invincibility_cooldown_timeout():
	invincible()


func get_random_item():
	var dblist = []
	for i in UpgradeDb.UPGRADES:
		if i in collected_upgrades: # find already collected upgrades
			pass
		elif i in upgrade_options: # if upgrade is already an option
			pass
		elif UpgradeDb.UPGRADES[i]["type"] == "item": # don't pick food
			pass
		elif UpgradeDb.UPGRADES[i]["prerequisite"].size() > 0:
			var to_add = true
			for n in UpgradeDb.UPGRADES[i]["prerequisite"]:
				if not n in collected_upgrades:
					to_add = false
			if to_add:
				dblist.append(i)
		else:
			dblist.append(i)
	
	if dblist.size() > 0:
		var randomitem = dblist.pick_random()
		upgrade_options.append(randomitem)
		return randomitem
	else:
		return null

func change_time(argtime: int = 0) -> void:
	time = argtime
	var get_m = int(time / 60.0)
	var get_s = time % 60
	if get_m < 10: # ensuring 2 digits
		get_m = str(0, get_m)
	if get_s < 10: # ensuring 2 digits
		get_s = str(0, get_s)
	labelTimer.text = str(get_m, ":", get_s)

func adjust_gui_collection(upgrade):
	var get_upgraded_displayname = UpgradeDb.UPGRADES[upgrade]["displayname"]
	var get_type = UpgradeDb.UPGRADES[upgrade]["type"]
	if get_type != "item":
		var get_collected_displaynames = []
		for i in collected_upgrades:
			get_collected_displaynames.append(UpgradeDb.UPGRADES[i]["displayname"])
		if not get_upgraded_displayname in get_collected_displaynames:
			var new_item = itemContainer.instantiate()
			new_item.upgrade = upgrade
			match get_type:
				"weapon":
					collectedWeapons.add_child(new_item)
				"upgrade":
					collectedUpgrades.add_child(new_item)
			
func death():
	deathPanel.visible = true
	
	emit_signal("playerDeath")

	_saver_loader.save_time()

	get_tree().paused = true

	var tween = deathPanel.create_tween()
	tween.tween_property(deathPanel, "position", Vector2(220, 50), 3.0).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.play()
	
	if time >= 300:
		labelResult.text = "You Win!"
		soundVictory.play()
	if time < 300:
		labelResult.text = "You Lose!"
		soundLose.play()
		

func _on_button_menu_click_end():
	get_tree().paused = false
	transition.play("fade_out")
	

func _on_transition_to_main_animation_finished(anim_name: StringName):
	var scene_level = "res://TitleScreen/menu.tscn"
	get_tree().change_scene_to_file(scene_level)
	# var _level = get_tree().change_scene_to_file("res://TitleScreen/menu.tscn")
