extends "res://Scripts/Player/ChildCube.gd"


@export var sprite : AnimatedSprite2D
@export var animator : AnimationPlayer

signal depower

func hit_nme():
	emit_signal("depower", id)

func relocate(y : int):
	animator.play("Appear")
	set_collision_mask_value(5, true)
	position.y = y
	velocity.y = 0
	move_and_slide()

func delocate():
	set_collision_mask_value(5, false)
