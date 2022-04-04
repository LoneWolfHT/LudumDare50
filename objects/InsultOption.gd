extends HBoxContainer

export(String) var LABEL = "oop, something broke"
export(String) var TRIGGER_ID
export(String) var TRIGGER_TARGET

func _ready():
	$Button.text = "\"" + LABEL + "\""


func _on_Button_button_up():
	if (TRIGGER_ID == TRIGGER_TARGET):
		get_parent().get_parent().get_parent().success()
	else:
		get_parent().get_parent().get_parent().failure()
