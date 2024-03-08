extends CharacterBody2D

const SPEED = 300.0

@export var cubes : Array[CharacterBody2D]
@export var camera : Camera2D
@export var camDistPx : int = 0
@export var cubeDist : int = 96
@export var jumpPlayer : AudioStreamPlayer

var PowerCube = preload("res://Scenes/PowerCube.tscn")
var PowerBoom = preload("res://Scenes/boom_sprite.tscn")

var timeBtwnSounds : float = 0.0
var leftBlockArray : Array[int]
var rightBlockArray : Array[int]
var moving_back_for_cutscene : bool = false
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
	for cube in cubes:
		cube.connect("help_stuck", child_stuck)
		cube.connect("unstuck", child_unstuck)
		cube.connect("jumpsound", jump_sound)
	set_cube_array_controls()
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
	elif (stuck == 1 || moving_back_for_cutscene):
		#stuck type 1 is right side blocked
		if (direction < 0 || moving_back_for_cutscene):
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
		if (moving_back_for_cutscene):
			moving_back_for_cutscene = false
			stuck = 3
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

func set_cube_array_controls():
	for index in range(cubes.size()):
		cubes[index].thisJumpLetter = str(index)
		cubes[index].id = index


func power_up():
	var newCube = PowerCube.instantiate()
	#reposition everything
	newCube.position = cubes[0].position
	newCube.position.x += cubeDist
	camDistPx -= cubeDist
	#connect it
	newCube.connect("help_stuck", child_stuck)
	newCube.connect("unstuck", child_unstuck)
	newCube.connect("jumpsound", jump_sound)
	newCube.connect("depower", depower)
	#add it to the cubes
	call_deferred("add_child", newCube)
	cubes.insert(0,newCube)
	#reset the physics things
	reposition(0)
	set_cube_array_controls()

func depower(index:int):
	#failsafe
	if (index >= 0 && index < cubes.size()):
		#check if stucc
		if (leftBlockArray.has(index)):
			leftBlockArray.erase(index)
			resetLeftArray()
		if (rightBlockArray.has(index)):
			rightBlockArray.erase(index)
			resetRightArray()
		#put bomb in place
		var boom = PowerBoom.instantiate()
		boom.position = cubes[index].position + position
		boom.linear_velocity = cubes[index].velocity + velocity
		get_parent().add_child(boom)
		#reposition everything
		remove_child(cubes[index])
		cubes.remove_at(index)
		camDistPx += cubeDist
		reposition(0)
		#reset the physics things
		set_cube_array_controls()

func back_up(direction : int):
	var lastcube : int = cubes.size()-1
	if (!cubes[lastcube].leftSideColliding()):
		moving_back_for_cutscene = true

func force_jump(index:int):
	cubes[index].force_jump()
