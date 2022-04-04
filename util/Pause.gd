extends Node

# Add init()                to your scene's _ready() to set up the default pause menu
# Add check_for_pause_key() to your scene's _input() to pause when pressing ESC
# Add pause_on_focus_lost() to your scene's _notification() to pause when focus is lost

var PauseRes = preload("../scenes/PauseMenu.tscn")
var PauseNode

var paused = false

func init(object):
	PauseNode = PauseRes.instance()

	object.add_child(PauseNode)

func _ready():
	pause_mode = PAUSE_MODE_PROCESS

func pause_on_focus_lost(notif):
	if (notif == MainLoop.NOTIFICATION_WM_FOCUS_OUT):
		pause()

func pause(custom_text = "Game Paused", pausenode = PauseNode):
	if (paused):
		return

	pausenode.get_node("Label").text = custom_text
	pausenode.visible = true

	get_tree().paused = true
	paused = true

func unpause(remove_node = false):
	if (!paused):
		return

	get_tree().paused = false

	if (remove_node):
		PauseNode.queue_free()
	else:
		PauseNode.visible = false

	paused = false

func check_for_pause_key(dont_handle = false):
	if Input.is_action_just_pressed("Pause_pause"):
		if (!dont_handle):
			if (paused):
				unpause()
			else:
				pause()

		return true

	return false
