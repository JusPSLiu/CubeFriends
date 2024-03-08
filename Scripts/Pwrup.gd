extends Area2D

@export var player : CharacterBody2D
@export var active : bool = true
@export var sound : AudioStreamPlayer2D

func _on_body_entered(body):
	if (visible):
		if (active and body.is_in_group("player")):
			player.power_up()
			visible = false
			active = false
			sound.play()
			await sound.finished
			for child in get_children():
				child.queue_free()
			queue_free()
