extends CanvasLayer

@export var buttonSoundPlayer : AudioStreamPlayer
@export var menu : Control
@export var ResumeButton : TextureButton
@export var soundSlider : HSlider
@export var musicSlider : HSlider
@export var Fader : AnimationPlayer
@export var MusicFader : AnimationPlayer
@export var esc_to_pause : bool = true
var disablePausing : bool = true

# Called when the node enters the scene tree for the first time.
func _ready():
	#make music and sound variables
	var musicVolume : float = AudioServer.get_bus_volume_db(2)
	var soundVolume : float = AudioServer.get_bus_volume_db(1)
	#set to music and sound variables iff not null
	if (musicVolume != null):
		musicSlider.value = (db_to_linear(musicVolume))
	if (soundVolume != null):
		soundSlider.value = (db_to_linear(soundVolume))
	#wait for opening transition to finish before allowing pausing
	await Fader.animation_finished
	disablePausing = false

func _input(event: InputEvent) -> void:
	if event is InputEventKey and !event.is_echo():
		if (event.keycode == KEY_ESCAPE and esc_to_pause):
			if event.pressed:
				togglePauseFall();

func togglePauseFall():
	if (!disablePausing):
		buttonSoundPlayer.play()
		get_tree().paused = !get_tree().paused
		menu.visible = !menu.visible
		ResumeButton.visible = !ResumeButton.visible


func _on_music_slider_value_changed(value):
	AudioServer.set_bus_volume_db(2, linear_to_db(value))


func _on_sound_slider_value_changed(value):
	AudioServer.set_bus_volume_db(1, linear_to_db(value))


func _on_exit_pressed():
	#save sound settings, so give out cookies here
	Singleton.give_free_cookies()
	MusicFader.play("FadeOut")
	Fader.play("FadeOut")
	buttonSoundPlayer.play()
	await Fader.animation_finished
	disablePausing = false
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/Screens/TitleScreen.tscn")
