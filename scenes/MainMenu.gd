extends Control

var enemy = preload("res://objects/Enemy.tscn")
var devanim = preload("res://objects/DeveloperAnim.tres")

var enemies = [
	{"HEALTH": 50 , "DAMAGE": 2 , "ATTACK_SPEED_MULT": 1               },
	{"HEALTH": 80 , "DAMAGE": 10, "ATTACK_SPEED_MULT": 1.1             },
	{"HEALTH": 100, "DAMAGE": 15, "ATTACK_SPEED_MULT": 1.2             },
	{"HEALTH": 110, "DAMAGE": 20, "ATTACK_SPEED_MULT": 1.3             },
	{"HEALTH": 100, "DAMAGE": 30, "ATTACK_SPEED_MULT": 1.2, "dev": true},
]

func _ready():
	$DevMenu.visible = false
	$Progress.max_value = enemies.size()
	$VictoryLabel.visible = false

	Pause.init(self)

	Pause.pause()

	$InsultMenu.start()

var pos = 0
func spawn_next_enemy():
	var newenemy = enemy.instance()

	newenemy.HEALTH = enemies[pos].HEALTH
	newenemy.DAMAGE = enemies[pos].DAMAGE
	newenemy.ATTACK_SPEED_MULT = enemies[pos].ATTACK_SPEED_MULT

	if ("dev" in enemies[pos]):
		newenemy.get_node("Anim").frames = devanim
		newenemy.WALK_SPEED -= 75
		newenemy.DEVELOPER = true

	newenemy.position = $EnemyPos.position

	$Progress.value = pos

	call_deferred("add_child_below_node", $EnemyPos, newenemy, true)
	pos += 1

func _on_SpawnTimer_timeout():
	spawn_next_enemy()

func _on_enemy_death():
	if (pos < enemies.size()):
		if (pos < enemies.size()-1):
			$InsultMenu.start()
		else:
			$DevMenu.visible = true
			$MainMusic.playing = false
			$DevMenu/Dev.play()
	else:
		$Progress.value = pos
		$DevDeath.play()
		$VictoryLabel.visible = true

func _input(_event):
	if ($InsultMenu.visible != true):
		Pause.check_for_pause_key()

func _notification(notif):
	if (get_node_or_null("InsultMenu") != null && $InsultMenu.visible != true):
		Pause.pause_on_focus_lost(notif)

func _on_InsultMenu_show():
	$Progress.visible = false
	$Player.CONTROLLABLE = false

func _on_InsultMenu_hide():
	$Progress.visible = true

	$Player.position = $EnemyPos.position
	$Player.CONTROLLABLE = true

	$Player._rolling = true
	$Player.CAN_ROLL = false
	$Player/Hitbox.monitoring = false
	$Player/RollTimer.start($Player.ROLL_TIME + 0.2)
	$Player.lock_look_dir()
	$Player.LOCK_VELOCITY = Vector2(0, 600)
	$Player.rotation = atan2(1, 0) + deg2rad(90)
	Audio.play("Roll")

	$SpawnTimer.start()

func _on_Play_button_up():
	$DevMenu.visible = false
	_on_InsultMenu_hide()

func _on_Dev_finished():
	$DevMenu/Play.visible = true
	$MainMusic.playing = true
