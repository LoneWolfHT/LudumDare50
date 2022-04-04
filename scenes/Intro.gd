extends Node2D

var done = false

func _ready():
	$AnimationPlayer.play("Main")

func play_teleport():
	Audio.play("Teleport")
