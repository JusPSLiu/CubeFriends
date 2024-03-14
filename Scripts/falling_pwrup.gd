extends RigidBody2D

@export var sound : AudioStreamPlayer2D

func _on_body_entered(body):
	if (visible):
		if (body.is_in_group("player")):
			body.get_parent().power_up()
			visible = false
			sound.play()
			await sound.finished
			for child in get_children():
				child.queue_free()
			queue_free()

func kms():
	visible = false
	for child in get_children():
		child.queue_free()
	queue_free()
