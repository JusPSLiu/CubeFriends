extends Area2D

@export var active : bool = true

func _on_body_entered(body):
	if (visible):
		if (active and body.is_in_group("holocube")):
			body.hit_nme()
			visible = false
			for child in get_children():
				child.queue_free()
			queue_free()

func _dont_die_but_entered(body):
	if (visible):
		if (active and body.is_in_group("holocube")):
			body.hit_nme()
