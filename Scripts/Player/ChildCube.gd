extends CharacterBody2D

@export var casteR : RayCast2D
@export var casteR2 : RayCast2D
@export var casteL : RayCast2D
@export var casteL2 : RayCast2D
@export var collider : CollisionShape2D
@export var nonrailcollider : RayCast2D
@export var nonrailcollider2 : RayCast2D
signal help_stuck
signal unstuck
signal jumpsound
signal railmode
signal derailed

var thisJumpLetter = 'p'
var id = 0
var coyoteTime : float = 0.1
var disabled = false
var isHoloCube = false
var rail_mode = false
var change_rail_mode_soon = false
var recently_derailed = false

const JUMP_VELOCITY = -800.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var i_am_stuck = 0

func _physics_process(delta):
	# Add the gravity.
	if is_on_floor():
		coyoteTime = 0.1
		if (change_rail_mode_soon):
			if (rail_mode and floor_is_not_rail()):
				rail_mode = false
				change_rail_mode_soon = false
				emit_signal("derailed")
			elif (!rail_mode and !floor_is_not_rail()):
				emit_signal("railmode", position.y)
				rail_mode = true
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
	
	if (i_am_stuck == 0):
		if (rightSideColliding()):
			if (leftSideColliding()):
				i_am_stuck = 3
				#signal
				emit_signal("help_stuck", 1, id)
				emit_signal("help_stuck", 2, id)
			else:
				#right collision == 1, left collision == 2
				i_am_stuck = 1
				#PHYSICSS
				collider.scale.x = 1.06
				move_and_slide()
				collider.scale.x = 0.9
				#signal
				emit_signal("help_stuck", 1, id)
		elif (leftSideColliding()):
			#left collision == 2
			i_am_stuck = 2
			#PHYSICSS
			collider.scale.x = 1.06
			move_and_slide()
			collider.scale.x = 0.9
			#signal
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

func floor_is_not_rail() -> bool:
	return nonrailcollider.is_colliding() or nonrailcollider2.is_colliding()

func force_jump():
	if (is_on_floor()):
		velocity.y = JUMP_VELOCITY
		emit_signal("jumpsound")

func enter_rail_mode():
	if (!isHoloCube):
		#call if not curr in rail mode, or if ur abt to drop rail mode
		if (!rail_mode):
			change_rail_mode_soon = true
		elif (change_rail_mode_soon):
			change_rail_mode_soon = false

func soon_exit_rail_mode():
	if (recently_derailed):
		recently_derailed = false
		set_collision_mask_value(5, true)
	elif (!isHoloCube and rail_mode):
		change_rail_mode_soon = true

#failsafe in case get stuck. i dont want ppl to softlock
func force_derail():
	set_collision_mask_value(5, false)
	change_rail_mode_soon = false
	rail_mode = false
	recently_derailed = true
