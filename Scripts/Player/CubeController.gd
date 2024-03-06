extends CharacterBody2D

const SPEED = 300.0

@export var cubes : Array[CharacterBody2D]
@export var camera : Camera2D
@export var camDistPx : int = 0
@export var cubeDist : int = 96
@export var jumpPlayer : AudioStreamPlayer
var timeBtwnSounds : float = 0.0


var leftBlockArray : Array[int]
var rightBlockArray : Array[int]
var stuck = 0
var disabled = false

func reposition(id:int):
	var currloc = cubes[id].position.x
	var curid = 0
	var offset = (id*-1*cubeDist) - (currloc)
	position.x -= offset
	cubes[id].position.x += offset
	if (!disabled):
		for cube in cubes:
			if (curid != id):
				cube.position.x = currloc+((id-curid)*cubeDist)+offset
				cube.velocity.x = 0
				# I am sick of the glitches so I'm forcing
				# EVERY COLLISION to check if EACH CUBE is stuck
				if (cube.checkIfStuck() != 3):
					if (cube.checkIfStuck() == 0):
						rightBlockArray.erase(curid)
						leftBlockArray.erase(curid)
					elif (cube.checkIfStuck() == 1):
						leftBlockArray.erase(curid)
						if (!rightBlockArray.has(curid)):
							rightBlockArray.append(curid)
					else:
						rightBlockArray.erase(curid)
						if (!leftBlockArray.has(curid)):
							leftBlockArray.append(curid)
			#have an index variable because my brain does not like for each loops
			curid+=1
	resetLeftArray()
	resetRightArray()
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
	if (timeBtwnSounds > 0):
		timeBtwnSounds-=delta
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
		if (!rightBlockArray.has(id)):
			rightBlockArray.append(id)
	elif (stuck == 2):
		if (!leftBlockArray.has(id)):
			leftBlockArray.append(id)
	else:
		if (!rightBlockArray.has(id)):
			rightBlockArray.append(id)
		if (!leftBlockArray.has(id)):
			leftBlockArray.append(id)

func child_unstuck(type, id):
	reposition(id)
	if (type == 1):
		rightBlockArray.erase(id)
		resetRightArray()
	elif (type == 2):
		leftBlockArray.erase(id)
		resetLeftArray()
	else:
		rightBlockArray.erase(id)
		leftBlockArray.erase(id)
		resetRightArray()
		resetLeftArray()

func resetRightArray():
	if (rightBlockArray.size() == 0):
		if (stuck == 1):
			stuck = 0
		else:
			stuck = 2
func resetLeftArray():
	if (leftBlockArray.size() == 0):
		if (stuck == 2):
			stuck = 0
		else:
			stuck = 1

func jump_sound():
	if (timeBtwnSounds <= 0):
		timeBtwnSounds = 0.02
		jumpPlayer.play()

func disable_children():
	for cube in cubes:
		cube.disable()
	stuck = 3
	velocity.x = move_toward(velocity.x, 0, SPEED)
	disabled = true
	move_and_slide()

func enable_children():
	for cube in cubes:
		cube.enable()
	stuck = 0
	disabled = false
	reposition(0)
