extends Control

export(Dictionary) var actions = {
	"move_up"    : {"label": "Move Up"    , "key": to_inputevent(KEY_W)},
	"move_left"  : {"label": "Move Left"  , "key": to_inputevent(KEY_A)},
	"move_down"  : {"label": "Move Down"  , "key": to_inputevent(KEY_S)},
	"move_right" : {"label": "Move Right" , "key": to_inputevent(KEY_D)},
	"attack"     : {"label": "Attack"     , "key": to_inputevent(KEY_J)},
	"roll"       : {"label": "Roll"       , "key": to_inputevent(KEY_K)},
}

var ActionNode = preload("res://objects/KeyChangeEntry.tscn")

func _ready():
	show_on_top = true
	pause_mode = PAUSE_MODE_PROCESS

	$Panel/Scroll/KeyList.anchor_right = 1

	if (!Settings.setting.keybinds.empty()):
		for action in Settings.setting.keybinds.keys():
			if (actions.has(action)):
				actions[action].key = to_inputevent(OS.find_scancode_from_string(Settings.setting.keybinds[action]))
			else: # remove action bind we don't have anymore
				Settings.setting.keybinds.erase(action)

	for action in actions:
		if (!InputMap.has_action(action)):
			add_keybind_entry(action)

	Settings.update() # Save any setting changes by add_keybind_entry above

func add_keybind_entry(entry):
	var keychangeentry = ActionNode.instance()

	keychangeentry.ACTION = entry
	keychangeentry.LABEL = actions[entry].label + " - "

	InputMap.add_action(entry)
	InputMap.action_add_event(entry, actions[entry].key)

	Settings.setting.keybinds[entry] = OS.get_scancode_string(actions[entry].key.scancode)

	$Panel/Scroll/KeyList.add_child(keychangeentry)

func to_inputevent(x):
	var out = InputEventKey.new()

	out.set_scancode(x)

	return out

func _on_Back_button_up():
	self.visible = false

func _on_AlwaysFaceEnemy_ready():
	$Panel/Scroll/KeyList/AlwaysFaceEnemies/Button.text = (Settings.setting.always_face_enemy as String)

func _on_AlwaysFaceEnemy_button_up():
	Settings.setting.always_face_enemy = !Settings.setting.always_face_enemy
	$Panel/Scroll/KeyList/AlwaysFaceEnemies/Button.text = (Settings.setting.always_face_enemy as String)
	Settings.update()
