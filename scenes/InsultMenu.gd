extends Panel

var triggers = {
	"PAY"      : {"label": "Does the developer pay you for this?" , "description": "look annoyed by recent events"                   },
	"THREAT"   : {"label": "Could you get out of the way?"        , "description": "are standing in front of the exit"               },
	"BAD_JOKE" : {"label": "Why did the chicken cross the road?"  , "description": "look like they enjoy good jokes"                 },
	"INSULT"   : {"label": "Zombies only eat brains, you're safe" , "description": "look around cautiously"                          },
	"INSULT2"  : {"label": "Huh, you're quite 2 dimensional"      , "description": "stare at you"                                    },
	"INSULT3"  : {"label": "Nothing?"                             , "description": "challenge you to guess what they're thinking of" },
}

var triggerlist = [
	"PAY",
	"THREAT",
	"BAD_JOKE",
	"INSULT",
	"INSULT2",
	"INSULT3",
]

var optionnode = preload("res://objects/InsultOption.tscn")

signal start
signal done

var reset = false

var rng = RandomNumberGenerator.new()
func _ready():
	self.visible = false

	rng.randomize()

	if (self.connect("start", get_parent(), "_on_InsultMenu_show") != OK):
		push_error("[InsultMenu] Failed to connect to main menu")

	if (self.connect("done", get_parent(), "_on_InsultMenu_hide") != OK):
		push_error("[InsultMenu] Failed to connect to main menu")

	for trigger in triggers:
		var newnode = optionnode.instance()

		newnode.LABEL = triggers[trigger].label
		newnode.TRIGGER_ID = trigger
		newnode.add_to_group("insult_option")

		$Scroll/OptionList.add_child(newnode)

func start():
	get_parent().get_node("PreInsultLabel").visible = true

func show():
	$Preview.texture.region.position.y = 0

	var selected_trigger = triggerlist[rng.randi_range(0, triggerlist.size()-1)]

	for child in $Scroll/OptionList.get_children():
		if (child.is_in_group("insult_option")):
			child.TRIGGER_TARGET = selected_trigger

	$Description.text = "They " + triggers[selected_trigger].description

func success():
	reset = false
	$Preview.texture.region.position.y = 16
	Audio.play("grrr")
	$HideTimer.start()

func failure():
	reset = true
	$Preview.texture.region.position.y = 8
	$HideTimer.start()

func _on_HideTimer_timeout():
	if (reset):
		show()
	else:
		self.visible = false
		emit_signal("done")

func _on_PreInsultLabel_button_up():
	get_parent().get_node("PreInsultLabel").visible = false
	emit_signal("start")
	show()
	self.visible = true
