extends CanvasLayer

@export var buttonSoundPlayer : AudioStreamPlayer
@export var menu : Control
@export var Fader : AnimationPlayer
var disablePausing : bool = true

# Called when the node enters the scene tree for the first time.
func _ready():
	await Fader.animation_finished
	disablePausing = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _input(event: InputEvent) -> void:
	if event is InputEventKey and !event.is_echo():
		if (event.keycode == KEY_ESCAPE):
			if event.pressed:
				togglePauseFall();

func togglePauseFall():
	if (!disablePausing):
		buttonSoundPlayer.play()
		get_tree().paused = !get_tree().paused
		menu.visible = !menu.visible
