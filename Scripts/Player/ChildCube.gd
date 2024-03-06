extends CharacterBody2D

@export var thisJumpLetter = 'p'
@export var casteR : RayCast2D
@export var casteR2 : RayCast2D
@export var casteL : RayCast2D
@export var casteL2 : RayCast2D
@export var Lable : Label
signal help_stuck
signal unstuck
signal jumpsound

var id = 0
var coyoteTime : float = 0.1
var disabled = false

const JUMP_VELOCITY = -800.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var i_am_stuck = 0

func _physics_process(delta):
	# Add the gravity.
	if is_on_floor():
		coyoteTime = 0.1
	else:
		velocity.y += gravity * delta
		if (coyoteTime > 0):
			coyoteTime -= delta
	
	# Handle jump.
	if Input.is_action_just_pressed(thisJumpLetter) and coyoteTime>0 and !disabled:
		velocity.y = JUMP_VELOCITY
		emit_signal("jumpsound")
	# move and slide
	move_and_slide()
	
	Lable.text = "stuckType: "+str(i_am_stuck)
	if (i_am_stuck == 0):
		if (rightSideColliding()):
			#right collision == 1, left collision == 2
			i_am_stuck = 1
			emit_signal("help_stuck", 1, id)
		elif (leftSideColliding()):
			#left collision == 2
			i_am_stuck = 2
			emit_signal("help_stuck", 2, id)
	else:
		if (i_am_stuck == 1):
			#if only the right side is stuck rn
			#right collision == 1
			if (!rightSideColliding()):
				i_am_stuck = 0
				emit_signal("unstuck", 1, id)
			elif (leftSideColliding()):
				i_am_stuck = 3
				emit_signal("help_stuck", 2, id)
		elif (i_am_stuck == 2):
			#if only the left side is stuck rn
			#left collision == 2
			if (!leftSideColliding()):
				i_am_stuck = 0
				emit_signal("unstuck", 2, id)
			elif (rightSideColliding()):
				i_am_stuck = 3
				emit_signal("help_stuck", 1, id)
		else:
			if (!rightSideColliding()):
				if (!leftSideColliding()):
					i_am_stuck = 0
					emit_signal("unstuck", 3, id)
				else:
					i_am_stuck = 2
					emit_signal("unstuck", 1, id)
			elif (!leftSideColliding()):
				i_am_stuck = 1
				emit_signal("unstuck", 2, id)

func disable():
	disabled = true

func enable():
	disabled = false

func rightSideColliding() -> bool:
	return (casteR.is_colliding() or casteR2.is_colliding())

func leftSideColliding() -> bool:
	return (casteL.is_colliding() or casteL2.is_colliding())

func checkIfStuck() -> int:
	return i_am_stuck
