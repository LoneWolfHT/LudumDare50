extends KinematicBody2D

const DEFAULT_WALK_SPEED = 350

export var DEVELOPER = false
export var ROLL_TIME = 0.3
export var ROLL_COOLDOWN = 0.3

export var HEALTH = 100
export var DAMAGE = 10
export var ATTACK_SPEED_MULT = 1

export var WALK_SPEED = DEFAULT_WALK_SPEED

export var CAN_ROLL = true
export var ATTACKING = false
export var WORRYING = false

export var LOCK_LOOK_DIR = false
export var LOCK_VELOCITY = Vector2()

var _rolling = false
onready var _target = get_parent().get_node("Player")

var skull = load("res://objects/Skull.tscn").instance()

signal died

func _ready():
	$Danger.monitorable = false
	$Hitbox.monitorable = false
	$Health/HealthTimer.start()

	if (self.connect("died", get_parent(), "_on_enemy_death") != OK):
		push_error("[Enemy] Failed to connect to main menu")

	$Sword.DAMAGE = DAMAGE
	$Sword/Anim.playback_speed = ATTACK_SPEED_MULT
	$Health.max_value = HEALTH
	$Health.value = HEALTH

func _on_Danger_area_entered(area:Area2D):
	if (area.get_parent() != _target):
		return

	worry()

	if (!_rolling && CAN_ROLL):
		if (!_target.ATTACKING && $Sword/Anim.current_animation != "Attack" && (!DEVELOPER || !_target._rolling)):
			$Sword.stab()

func _on_Danger_area_exited(area:Area2D):
	if (area.get_parent() != _target):
		return

	unworry()

var worrying_queue = []
func worry():
	worrying_queue.append(true)

	WORRYING = true

func unworry():
	if (worrying_queue.size() <= 0):
		return

	worrying_queue.remove(0)

	if (worrying_queue.size() <= 0):
		WORRYING = false

var lock_look_dir_queue = []
func lock_look_dir():
	lock_look_dir_queue.append(true)

	LOCK_LOOK_DIR = true

func unlock_look_dir():
	if (lock_look_dir_queue.size() <= 0):
		return

	lock_look_dir_queue.remove(0)

	if (lock_look_dir_queue.size() <= 0):
		LOCK_LOOK_DIR = false

func _physics_process(_delta):
	if (!is_instance_valid(_target)):
		return

	var velocity = LOCK_VELOCITY

	if (velocity.x == 0 && velocity.y == 0):
		velocity = self.position.direction_to(_target.position) * WALK_SPEED

	if (!_rolling && !CAN_ROLL):
		velocity *= -0.2

	if (!_rolling && CAN_ROLL):
		if (WORRYING):
			_rolling = true
			CAN_ROLL = false
			$RollTimer.start(ROLL_TIME)
			$Hitbox.monitoring = false
			Audio.play_low("Roll", -5)

			if (velocity.x != 0 and velocity.y != 0):
				LOCK_VELOCITY = velocity * -2
			else:
				LOCK_VELOCITY = velocity * -2.4

			lock_look_dir()
			self.rotation = atan2(velocity.y, velocity.x) + deg2rad(90)

	handle_anims(velocity.normalized())

	velocity = move_and_slide(velocity, Vector2(), false, 2)

func handle_anims(dir):
	var rotdir = self.position.direction_to(_target.position)

	if (dir.length() > 0):
		if (_rolling):
			$Anim.play("roll")
		else:
			$Anim.play("walk")
	else:
		$Anim.play("stand")

	if (!LOCK_LOOK_DIR):
		self.rotation = atan2(rotdir.y, rotdir.x) + deg2rad(90)


func _on_RollTimer_timeout():
	if (_rolling):
		_rolling = false
		LOCK_VELOCITY /= 2.2
		unlock_look_dir()
		$Hitbox.monitoring = true

		var found = false
		for area in $Danger.get_overlapping_areas():
			if (!is_instance_valid(_target) || area.get_parent() == _target):
				found = true
				break

		if (!found):
			unworry()
			$RollTimer.start(ROLL_COOLDOWN)
		else: #They chased us, cancel dodge early
			LOCK_VELOCITY = Vector2()
			CAN_ROLL = true
			$Sword.stab()
	elif (!CAN_ROLL):
		LOCK_VELOCITY = Vector2()
		CAN_ROLL = true


func _on_Hitbox_area_entered(area:Area2D):
	if (area.is_in_group("sword") && area != $Sword/Texture/Area):
		var sword = area.get_parent().get_parent()

		if (sword.DAMAGE_DEALT):
			return

		sword.DAMAGE_DEALT = true
		$Blood.emitting = true
		$Blood.restart()
		$Health.value -= sword.DAMAGE

func _on_Health_value_changed(value:float):
	Audio.play_low("Hit", -5)

	if (value <= 0):
		emit_signal("died")
		skull.position = self.position

		if (!DEVELOPER):
			skull.get_node("Skull").visible = true
		else:
			skull.get_node("DevSkull").visible = true

		get_parent().get_node("Background").add_child(skull)
		queue_free()

	$Health.visible = true
	$Health/HealthTimer.start()

func _on_HealthTimer_timeout():
	$Health.visible = false
