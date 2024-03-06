extends Node


var currentLevel : int = 1
var unlockedLevel : int = 1
var enabledTextSkip : bool = false
var numLevels : int = 5
var coinsCollected : Array = [false,false,false,false,false]

func _ready():
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
		
		#I added coins later so check if thats there and if so set the coins
		if data.has("c"):
			coinsCollected = data["c"]

func hasCoin(index:int) -> bool:
	if (index < 0 or index >= coinsCollected.size()):
		return false
	return coinsCollected[index]

func getCoin(index:int):
	if (coinsCollected[index] == false):
		coinsCollected[index] = true
		give_free_cookies()

func give_free_cookies():
	var save_file = FileAccess.open("user://cube_fren.save", FileAccess.WRITE)
	save_file.store_var({
		"L" : unlockedLevel,
		"skp" : enabledTextSkip,
		"s" : AudioServer.get_bus_volume_db(1),
		"m" : AudioServer.get_bus_volume_db(2),
		"c" : coinsCollected
	})
	save_file.close()

