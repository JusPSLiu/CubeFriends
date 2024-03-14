extends RigidBody2D



func _on_body_entered(body):
	if (visible):
		if (body.is_in_group("holocube")):
			body.hit_nme()
			visible = false
			for child in get_children():
				child.queue_free()
			queue_free()

func _dont_die_but_entered(body):
	if (visible):
		if (body.is_in_group("holocube")):
			body.hit_nme()
