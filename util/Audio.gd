extends Node

var BASE_VOL = -30

var sounds = {}

# You can add sounds here
func _ready():
	new_sound("Teleport", -6)
	new_sound("Hit", 4)
	new_sound("Roll", 8)
	new_sound("select", -3)
	new_sound("Slash", 14)
	new_sound("grrr", 12)

func new_sound(name, volume):
	var audionode = AudioStreamPlayer.new()

	audionode.volume_db = BASE_VOL + volume
	audionode.stream = load("res://assets/audio/" + name + ".wav")
	sounds[name] = {"node": audionode, "playpos": 0, volume = volume}

	add_child(audionode)

	print("Loaded Audio "+name)

var _time = 0
func _process(delta):
	_time += delta

	if _time >= 0.5:
		_time = 0

		for sound in sounds:
			if (!sounds[sound].node.playing):
				sounds[sound].node.volume_db = BASE_VOL + Settings.setting.audio_volume_shift + sounds[sound].volume

func play(sound_name):
	if sounds[sound_name]:
		sounds[sound_name].node.play()

func play_low(sound_name, vol_shift):
	if sounds[sound_name]:
		sounds[sound_name].node.volume_db += vol_shift
		sounds[sound_name].node.play()

func resume(sound_name):
	if sounds[sound_name]:
		sounds[sound_name].node.play(sounds[sound_name].playpos)

func stop(sound_name):
	if sounds[sound_name]:
		sounds[sound_name].playpos = sounds[sound_name].node.get_playback_position()
		sounds[sound_name].node.stop()
