extends Area2D

@export var OnlyOnce : bool = true
@export var coinID : int = -1
@export var coinSprite : Sprite2D
@export var coinSound : AudioStreamPlayer2D

func _ready():
	if (coinID > -1):
		if (Singleton.hasCoin(coinID)):
			coinSprite.texture = load("res://Art/coinGot.png")
			coinSprite.modulate.a = 0.5

func _on_body_entered(body):
	if (visible):
		if (OnlyOnce and body.is_in_group("player")):
			if (coinID > -1):
				visible = false
				coinSound.play()
				Singleton.getCoin(coinID)
				await coinSound.finished
			for child in get_children():
				child.queue_free()
			queue_free()

func disable_this():
	for child in get_children():
		child.queue_free()
	queue_free()
