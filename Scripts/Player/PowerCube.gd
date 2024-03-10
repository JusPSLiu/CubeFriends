extends "res://Scripts/Player/ChildCube.gd"


@export var sprite : AnimatedSprite2D

signal depower

func hit_nme():
	emit_signal("depower", id)
