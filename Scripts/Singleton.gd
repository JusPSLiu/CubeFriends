extends Node


var currentLevel : int = 1
var unlockedLevel : int = 1
var enabledTextSkip : bool = false
var numLevels : int = 5

func _ready():
	var save_file = FileAccess.open("user://cube_fren.save", FileAccess.READ)
	if (save_file != null):
		unlockedLevel = save_file.get_as_text().to_int()
		currentLevel = unlockedLevel
		if currentLevel > numLevels:
			currentLevel = numLevels

func give_free_cookies():
	var save_file = FileAccess.open("user://cube_fren.save", FileAccess.WRITE)
	save_file.store_string("%s" % unlockedLevel)

