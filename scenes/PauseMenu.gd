extends Control

func _ready():
	show_on_top = true
	pause_mode = PAUSE_MODE_PROCESS

	self.visible = false
	$KeybindMenu.visible = false

func _on_Resume_button_up():
	Pause.unpause()

func _on_Keybinds_button_up():
	$KeybindMenu.visible = true

func _on_Exit_button_up():
	Quit.quit()

func _on_MainMenu_button_up():
	Pause.unpause()
