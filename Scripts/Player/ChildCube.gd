extends CharacterBody2D

@export var thisJumpLetter = 'p'
@export var casteR : RayCast2D
@export var casteL : RayCast2D
signal help_stuck
signal unstuck
signal jumpsound

var id = 0
var coyoteTime : float = 0.1

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
	if Input.is_action_just_pressed(thisJumpLetter) and coyoteTime>0:
		velocity.y = JUMP_VELOCITY
		emit_signal("jumpsound")
	# move and slide
	move_and_slide()
	
	if (i_am_stuck == 0):
		if (casteR.is_colliding()):
			#right collision == 1, left collision == 2
			i_am_stuck = 1
			emit_signal("help_stuck", 1, id)
		elif (casteL.is_colliding()):
			#left collision == 2
			i_am_stuck = 2
			emit_signal("help_stuck", 2, id)
	else:
		if (i_am_stuck == 1):
			if (!casteR.is_colliding()):
				i_am_stuck = 0
				emit_signal("unstuck", 1, id)
		else:
			if (!casteL.is_colliding()):
				i_am_stuck = 0
				emit_signal("unstuck", 2, id)
