extends Node

var BASE_VOL = 0

func _ready():
	BASE_VOL = self.volume_db
	self.volume_db = BASE_VOL + Settings.setting.audio_volume_shift

var _time = 0
func _process(delta):
	_time += delta

	if _time >= 0.5:
		_time = 0

		self.volume_db = BASE_VOL + Settings.setting.audio_volume_shift
