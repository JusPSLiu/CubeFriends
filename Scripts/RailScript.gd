extends Area2D


func _on_body_entered(body):
	if (body.is_in_group("player")):
		print_debug("PLAYER IS HERE")
		if (!body.isHoloCube):
			body.enter_rail_mode()


func _on_body_exited(body):
	if (body.is_in_group("player")):
		if (!body.isHoloCube):
			print_debug("PLAYER IS LEFT")
			body.soon_exit_rail_mode()
