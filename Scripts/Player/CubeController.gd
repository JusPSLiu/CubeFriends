extends CharacterBody2D

const SPEED = 300.0

@export var cubes : Array[CharacterBody2D]
@export var camera : Camera2D
@export var camDistPx : int = 0
@export var jumpPlayer : AudioStreamPlayer


var leftBlockArray : Array[int]
var rightBlockArray : Array[int]
var stuck = 0

func reposition(id:int):
	var currloc = cubes[id].position.x
	var curid = 0
	for cube in cubes:
		if (curid != id):
			cube.position.x = currloc+((id-curid)*96)
			cube.velocity.x = 0
		curid+=1
	camera.position.x = cubes[0].position.x + camDistPx

func _ready():
	var id=0
	for cube in cubes:
		cube.id = id
		cube.connect("help_stuck", child_stuck)
		cube.connect("unstuck", child_unstuck)
		cube.connect("jumpsound", jump_sound)
		id+=1
	reposition(0)

func _physics_process(delta):
	var direction = Input.get_axis("ui_left", "ui_right")
	if (stuck == 0):
		#not stuck; regular motion
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	elif (stuck == 1):
		#stuck type 1 is right side blocked
		if (direction < 0):
			velocity.x = -SPEED
		else:
			velocity.x = 0
	elif (stuck == 2):
		#stuck type 2 is left side blocked
		if (direction > 0):
			velocity.x = SPEED
		else:
			velocity.x = 0
	move_and_slide()

func child_stuck(type, id):
	reposition(id)
	if (stuck == 0):
		stuck = type
	else:
		if (stuck != type):
			#stuck type 3 is if both sides blocked
			stuck = 3
	#failsafe in case more than one box is colliding
	if (stuck == 1):
		rightBlockArray.append(id)
	else:
		leftBlockArray.append(id)

func child_unstuck(type, id):
	reposition(id)
	if (type == 1):
		rightBlockArray.erase(id)
		if (rightBlockArray.size() == 0):
			if (stuck == 1):
				stuck = 0
			else:
				stuck = 2
	else:
		leftBlockArray.erase(id)
		if (leftBlockArray.size() == 0):
			if (stuck == 2):
				stuck = 0
			else:
				stuck = 1

func jump_sound():
	jumpPlayer.play()
