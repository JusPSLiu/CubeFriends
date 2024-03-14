extends Node2D

@export var animationplayer : AnimationPlayer
@export var healthbar : TextureRect

var health : int = 17 # a contract is a contract is a contract but only between ferengi
var nme_droppy = load("res://Scenes/nme_drop.tscn")
var pwrup_droppy = load("res://Scenes/specialthings/falling_pwrup.tscn")


func StartBoss():
	animationplayer.play("start")
	healthbar.scale.y = health
	await animationplayer.animation_finished
	animationplayer.play("cycle")

func damage_boss():
	health -= 1;
	if (health >= 0):
		healthbar.scale.y = health
	else:
		animationplayer.play("die")


func _on_hitbox_body_entered(body):
	if (body.is_in_group("holocube")):
		body.hit_nme()
		damage_boss()

func drop_nme():
	var newDroppy = nme_droppy.instantiate()
	newDroppy.position = position
	get_parent().add_child(newDroppy)

func drop_pwrup():
	var newDroppy = pwrup_droppy.instantiate()
	newDroppy.position = position
	get_parent().add_child(newDroppy)
