extends VScrollBar

func _ready():
	self.value = Settings.setting.difficulty
	_update_label()

func _update_label():
	$Label.text = "Difficulty: x" + (self.value as String)

var queue_update = false
var timer = 0
func _process(delta):
	if (!queue_update):
		return

	timer = timer + delta

	if (timer >= 3):
		queue_update = false
		Settings.update()


func _on_VolumeSlider_value_changed(value:float):
	Settings.setting.difficulty = value
	_update_label()
	queue_update = true
