extends Button

export(String, FILE, "*.tscn") var load_scene

func _ready():
	if (self.connect("button_up", self, "_on_button_up") != OK):
		push_error("[util->buttonpress] Failed to connect sceneload func to buttonpress signal")

func _on_button_up():
	Audio.play("select")

	if (load_scene && get_tree().change_scene(load_scene) != OK):
		push_error("[util->buttonpress] Failed to change scene on buttonpress")
