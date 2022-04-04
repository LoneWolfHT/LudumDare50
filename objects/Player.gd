extends KinematicBody2D

const DEFAULT_WALK_SPEED = 350
const ROLL_TIME = 0.3
const ROLL_COOLDOWN = 0.3

export var WALK_SPEED = DEFAULT_WALK_SPEED
export var CONTROLLABLE = true
export var CAN_ROLL = true
export var ATTACKING = false

export var LOCK_LOOK_DIR = false
export var LOCK_VELOCITY = Vector2()

var DIFFICULTY_MULT = Settings.setting.difficulty
var _rolling = false

func _ready():
	$Health/HealthTimer.start()
	$RestartButton.visible = false

var queue = []
func lock_look_dir():
	queue.append(true)

	LOCK_LOOK_DIR = true

func unlock_look_dir():
	if (queue.size() <= 0):
		return

	queue.remove(0)

	if (queue.size() <= 0):
		LOCK_LOOK_DIR = false

func _physics_process(_delta):
	if (!CONTROLLABLE):
		return

	DIFFICULTY_MULT = Settings.setting.difficulty

	var velocity = LOCK_VELOCITY

	if (velocity.x == 0 && velocity.y == 0):
		if Input.is_action_pressed("move_left"):
			velocity.x = -WALK_SPEED
		elif Input.is_action_pressed("move_right"):
			velocity.x = WALK_SPEED
		if Input.is_action_pressed("move_up"):
			velocity.y = -WALK_SPEED
		elif Input.is_action_pressed("move_down"):
			velocity.y = WALK_SPEED

	if (!_rolling && CAN_ROLL):
		if (Input.is_action_pressed("roll") || Input.is_mouse_button_pressed(BUTTON_RIGHT)):
			_rolling = true
			CAN_ROLL = false
			$Hitbox.monitoring = false
			$RollTimer.start(ROLL_TIME)
			Audio.play("Roll")

			if (velocity.x != 0 and velocity.y != 0):
				LOCK_VELOCITY = velocity * 2
			else:
				LOCK_VELOCITY = velocity * 2.4

			lock_look_dir()
			self.rotation = atan2(velocity.y, velocity.x) + deg2rad(90)
		elif (Input.is_action_pressed("attack") || Input.is_mouse_button_pressed(BUTTON_LEFT)):
			if ($Sword/Anim.current_animation != "Attack"):
				$Sword/Anim.playback_speed = 1 / DIFFICULTY_MULT
				$Sword.DAMAGE = 10 / DIFFICULTY_MULT
				$Sword.stab()

	handle_anims(velocity.normalized())

	velocity = move_and_slide(velocity, Vector2(), false, 2)

func handle_anims(dir):
	var rotdir

	if (get_parent().has_node("Enemy") && Settings.setting.always_face_enemy):
		rotdir = self.position.direction_to(get_parent().get_node("Enemy").position)
	else:
		rotdir = self.position.direction_to(get_viewport().get_mouse_position())

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
		LOCK_VELOCITY = Vector2()
		$Hitbox.monitoring = true
		$RollTimer.start(ROLL_COOLDOWN * DIFFICULTY_MULT)
		unlock_look_dir()
	elif (!CAN_ROLL):
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
	Audio.play("Hit")
	if (value <= 0):
		$DeathTimer.start()
		CONTROLLABLE = false

	$Health.visible = true
	$Health/HealthTimer.start()

func _on_HealthTimer_timeout():
	$Health.visible = false

func _on_DeathTimer_timeout():
	$RestartButton.visible = true
	self.rotation = 0
