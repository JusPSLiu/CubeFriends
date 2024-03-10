extends RigidBody2D

@export var light : Light2D

# Called when the node enters the scene tree for the first time.
func _ready():
	await get_child(0).animation_finished
	queue_free()


func process(delta):
	light.scale -= delta*.2
