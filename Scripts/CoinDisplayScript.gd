extends TextureRect

@export var id : int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	if (Singleton.hasCoin(id)):
		texture = load("res://Art/coin.png")
