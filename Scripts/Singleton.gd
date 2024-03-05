extends Node


var currentLevel : int = 1
var unlockedLevel : int = 1
var enabledTextSkip : bool = true
var numLevels : int = 5

func _ready():
	var dah = {
		"L" : unlockedLevel,
		"skp" : enabledTextSkip,
		"s" : AudioServer.get_bus_volume_db(1),
		"m" : AudioServer.get_bus_volume_db(2)
	}
	print(dah["L"])
	
	var save_file = FileAccess.open("user://cube_fren.save", FileAccess.READ)
	if (save_file != null):
		var data = save_file.get_var()
		unlockedLevel = data["L"]
		currentLevel = unlockedLevel
		if currentLevel > numLevels:
			currentLevel = numLevels
		print(currentLevel)
		
		#get the textskip, sound volume, and music volume now
		enabledTextSkip = data["skp"]
		AudioServer.set_bus_volume_db(1, data["s"])
		AudioServer.set_bus_volume_db(2, data["m"])

func give_free_cookies():
	var save_file = FileAccess.open("user://cube_fren.save", FileAccess.WRITE)
	save_file.store_var({
		"L" : unlockedLevel,
		"skp" : enabledTextSkip,
		"s" : AudioServer.get_bus_volume_db(1),
		"m" : AudioServer.get_bus_volume_db(2)
	})
	save_file.close()

