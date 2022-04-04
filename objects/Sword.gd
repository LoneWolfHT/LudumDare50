extends Node

export var DAMAGE = 10

var DAMAGE_DEALT = false

func _ready():
	$Texture.visible = false
	$Texture/Area.set_deferred("monitorable", false)

func stab():
	$Anim.play("Attack")
	Audio.play("Slash")

func _on_Sword_animation_started(_anim):
	var parent = get_parent()

	DAMAGE_DEALT = false
	parent.WALK_SPEED = 100
	parent.lock_look_dir()
	parent.CAN_ROLL = false
	parent.ATTACKING = true
	$Texture/Area.set_deferred("monitorable", true)

func _on_Sword_animation_finished(_anim):
	var parent = get_parent()

	parent.WALK_SPEED = parent.DEFAULT_WALK_SPEED
	parent.unlock_look_dir()
	parent.CAN_ROLL = true
	parent.ATTACKING = false
	$Texture/Area.set_deferred("monitorable", false)

func _on_Area_area_entered(_area:Area2D):
	pass
