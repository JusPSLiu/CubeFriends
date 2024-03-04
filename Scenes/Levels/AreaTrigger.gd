extends Area2D

@export var OnlyOnce : bool = true

func _on_body_entered(body):
	if (OnlyOnce and body.is_in_group("player")):
		for child in get_children():
			child.queue_free()
		queue_free()
